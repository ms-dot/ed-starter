## Project Overview
RunwayBriefing - FIDS app. Next.js 16 App Router, React 19, TypeScript 5, Zustand 5, Tailwind 4.

## Project Structure
```
app/                    # Next.js App Router
├── page.tsx            # FIDS public board (home)
├── layout.tsx          # Root layout
├── globals.css         # Global styles (Tailwind)
├── admin/page.tsx      # Admin panel
└── api/flights/        # REST API
    ├── route.ts        # GET/POST/PUT/DELETE flights
    ├── reset/          # Reset endpoint
    └── stats/          # Stats endpoint
components/
├── fids/              # Public-facing FIDS components
│   ├── FlightBoard.tsx
│   ├── FlightRow.tsx
│   ├── LiveClock.tsx
│   └── StatusBadge.tsx
└── admin/             # Admin panel components
    ├── FlightEditor.tsx
    └── StatusControl.tsx
store/flightsStore.ts  # Zustand state management
lib/
├── flights.ts         # Flight data helpers
└── utils.ts           # Shared utilities
types/index.ts         # TypeScript type definitions
data/
├── flights.json       # Flight data (runtime)
└── flights.seed.json  # Seed/default data
__tests__/             # Vitest tests
.ai/spec.md            # Project specification
```

## Coding Standards
- ES modules, path aliases (@/types, @/lib, @/store)
- Prefer const over let
- API routes: NextResponse.json()
- Types in types/index.ts, state in store/flightsStore.ts

## Constraints
- Do not install additional dependencies without explicit approval
- Do not modify data/flights.seed.json — it is the source of truth for resets
- Keep all components client-side only ("use client") unless explicitly marked as Server Components
- Never store secrets or API keys in source code — use environment variables

## Workflow
```bash
npm run dev          # Start dev server
npm run build        # Production build
npm run test         # Run tests (Vitest)
npm run typecheck    # Type-check (tsc --noEmit)
npm run lint         # Lint (ESLint)
npm run format       # Format (Prettier)
```
