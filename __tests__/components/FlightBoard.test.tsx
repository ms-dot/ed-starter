import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { cleanup, fireEvent, render, screen, waitFor } from '@testing-library/react';
import { FlightBoard } from '@/components/fids/FlightBoard';
import { useFlightsStore } from '@/store/flightsStore';
import type { Flight } from '@/types';

vi.mock('@/components/fids/LiveClock', () => ({
  LiveClock: () => <div data-testid="live-clock">12:00:00</div>,
}));

const mockFlights: Flight[] = [
  {
    id: '1',
    flightNumber: 'RB101',
    airline: 'LOT',
    destination: 'Warsaw',
    departureTime: '08:30',
    terminal: 'T1',
    gate: 'A1',
    status: 'On Time',
  },
  {
    id: '2',
    flightNumber: 'RB202',
    airline: 'Ryanair',
    destination: 'Dublin',
    departureTime: '09:15',
    terminal: 'T2',
    gate: 'B4',
    status: 'Boarding',
  },
  {
    id: '3',
    flightNumber: 'RB303',
    airline: 'Lufthansa',
    destination: 'Frankfurt',
    departureTime: '10:45',
    terminal: 'T1',
    gate: 'C2',
    status: 'Delayed',
    delayMinutes: 20,
  },
];

function renderFlightBoard(flights: Flight[]) {
  render(<FlightBoard initialFlights={flights} />);
}

async function waitForFlight(flightNumber: string) {
  await screen.findByText(flightNumber);
}

beforeEach(() => {
  useFlightsStore.setState({
    flights: [],
    filters: {
      terminal: 'All',
      airline: 'All',
      status: 'All',
    },
  });
  vi.clearAllMocks();
});

afterEach(() => {
  cleanup();
});

describe('FlightBoard', () => {
  it('renders flight list', async () => {
    renderFlightBoard(mockFlights.slice(0, 2));

    expect(await screen.findByText('RB101')).toBeInTheDocument();
    expect(screen.getByText('Warsaw')).toBeInTheDocument();
    expect(screen.getByText('RB202')).toBeInTheDocument();
    expect(screen.getByText('Dublin')).toBeInTheDocument();
  });

  it('filters by terminal', async () => {
    renderFlightBoard(mockFlights);
    await waitForFlight('RB101');

    fireEvent.change(screen.getByDisplayValue('All Terminals'), {
      target: { value: 'T1' },
    });

    await waitFor(() => {
      expect(screen.getByText('RB101')).toBeInTheDocument();
      expect(screen.getByText('RB303')).toBeInTheDocument();
      expect(screen.queryByText('RB202')).not.toBeInTheDocument();
    });
  });

  it('filters by airline', async () => {
    renderFlightBoard(mockFlights);
    await waitForFlight('RB101');

    fireEvent.change(screen.getByDisplayValue('All Airlines'), {
      target: { value: 'Ryanair' },
    });

    await waitFor(() => {
      expect(screen.getByText('RB202')).toBeInTheDocument();
      expect(screen.queryByText('RB101')).not.toBeInTheDocument();
      expect(screen.queryByText('RB303')).not.toBeInTheDocument();
    });
  });

  it('filters by status', async () => {
    renderFlightBoard(mockFlights);
    await waitForFlight('RB101');

    fireEvent.change(screen.getByDisplayValue('All Statuses'), {
      target: { value: 'Delayed' },
    });

    await waitFor(() => {
      expect(screen.getByText('RB303')).toBeInTheDocument();
      expect(screen.queryByText('RB101')).not.toBeInTheDocument();
      expect(screen.queryByText('RB202')).not.toBeInTheDocument();
    });
  });

  it('shows empty state', () => {
    renderFlightBoard([]);

    expect(screen.getByText('No flights match the current filters.')).toBeInTheDocument();
  });

  it('shows empty state after filtering', async () => {
    renderFlightBoard(mockFlights.slice(0, 2));
    await waitForFlight('RB101');

    fireEvent.change(screen.getByDisplayValue('All Statuses'), {
      target: { value: 'Cancelled' },
    });

    await waitFor(() => {
      expect(screen.getByText('No flights match the current filters.')).toBeInTheDocument();
    });
  });

  it('displays correct flight count', async () => {
    renderFlightBoard(mockFlights);
    await waitForFlight('RB101');

    expect(screen.getByText('3 flights')).toBeInTheDocument();

    fireEvent.change(screen.getByDisplayValue('All Statuses'), {
      target: { value: 'Boarding' },
    });

    await waitFor(() => {
      expect(screen.getByText('1 flight')).toBeInTheDocument();
      expect(screen.getByText('RB202')).toBeInTheDocument();
      expect(screen.queryByText('RB101')).not.toBeInTheDocument();
      expect(screen.queryByText('RB303')).not.toBeInTheDocument();
    });
  });
});
