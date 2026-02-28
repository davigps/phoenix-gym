# PhoenixGym — Implementation Plan

> A mobile-first gym workout tracker built with Phoenix LiveView + DaisyUI, cloning the core features of the Hevy app.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Tech Stack](#2-tech-stack)
3. [Feature List](#3-feature-list)
4. [Data Models & Schema](#4-data-models--schema)
5. [Application Structure](#5-application-structure)
6. [UI / Navigation Design](#6-ui--navigation-design)
7. [Implementation Phases](#7-implementation-phases)
8. [Page-by-Page Breakdown](#8-page-by-page-breakdown)
9. [Component Library](#9-component-library)
10. [State Management Strategy](#10-state-management-strategy)
11. [Seeding the Exercise Library](#11-seeding-the-exercise-library)

---

## 1. Project Overview

PhoenixGym is a Hevy-inspired workout tracking Progressive Web App (PWA). Users can:

- Browse and manage a curated **exercise library** (pre-seeded + custom exercises)
- Build reusable **workout routines** from exercises
- **Log live workouts** with sets, reps, weight, and RPE — while seeing their last performance for each exercise inline
- Review **workout history** with per-session volume, duration, and PRs
- Track **personal records** and view progress charts

The app is **mobile-first**, using a bottom tab bar navigation pattern identical to Hevy.

---

## 2. Tech Stack

| Layer | Technology |
|---|---|
| Web Framework | Phoenix 1.8.1 + LiveView 1.1.0 |
| Database | PostgreSQL via Ecto |
| CSS | Tailwind CSS v4.1.7 + DaisyUI (vendored) |
| Icons | Heroicons v2.2.0 |
| JS Bundler | esbuild (ES2022, no npm) |
| Server | Bandit |

---

## 3. Feature List

### 3.1 Exercise Library

- Pre-seeded list of 200+ common exercises (covering all muscle groups and equipment)
- Each exercise has: name, primary muscle group, secondary muscles, equipment, category (strength, cardio, olympic, plyometric, etc.), optional description
- User can add **custom exercises** with the same fields
- Search and filter by muscle group, equipment, and category
- Exercises are shared (global) but custom exercises are user-visible to all (MVP) or per-user (future)

### 3.2 Routines

- Create named routines with optional notes
- Add exercises to a routine with a configurable **target set count** per exercise
- Reorder exercises via drag-and-drop (or up/down buttons on mobile)
- Delete exercises from routine
- Edit existing routines
- Duplicate routines
- Start a workout from a routine (pre-populates exercises and sets)

### 3.3 Active Workout (Live Logging)

- Start a workout from scratch or from a routine
- A persistent workout session tracked in LiveView state and Ecto
- For each exercise in the workout:
  - Display exercise name and muscle group badge
  - Show **last session's sets** (weight × reps) for reference — inline, above current sets
  - Add/remove sets dynamically
  - Per set: set type (Warm-up `W`, Normal, Drop Set `D`), weight (kg/lbs), reps, optional RPE (1–10)
  - Mark each set as completed with a checkbox — completed sets turn green
  - Rest timer: configurable auto-start after completing a set (countdown shown in sticky header)
- Add more exercises mid-workout from the exercise library
- Reorder exercises
- Add workout notes
- **Finish Workout**: saves session with elapsed time, total volume, total sets, total reps
- **Discard Workout**: prompt to confirm then delete in-progress session
- Timer in header shows elapsed workout time

### 3.4 Workout History

- Chronological list of completed workouts
- Each card shows: date/time, routine name (if used), duration, total volume, exercises performed
- Tap to view full workout detail
- Search/filter history by date range or exercise name

### 3.5 Workout Detail View

- Full breakdown of a past workout
- Exercise → sets table with weight, reps, type
- Total volume, duration, PRs achieved in that session highlighted

### 3.6 Personal Records (PRs)

- Automatically tracked per exercise: **1RM estimated**, **max weight**, **max reps**, **max volume in single set**, **max volume in single session**
- PRs displayed in exercise detail page and highlighted during active workout when beaten

### 3.7 Stats / Dashboard

- Weekly volume bar chart (last 8 weeks)
- Workouts per week summary
- Most trained muscle groups (donut chart)
- Recent PRs
- Streak counter (consecutive workout days/weeks)

### 3.8 Profile

- User name (no auth in MVP — single-user or session-based)
- Unit preference: kg or lbs
- Theme toggle: light / dark / system

---

## 4. Data Models & Schema

### 4.1 Exercises (`exercises`)

```
id            :bigserial primary key
name          :string not null
category      :string              -- "strength", "cardio", "olympic", "plyometric", "flexibility", "other"
primary_muscle :string             -- "chest", "back", "shoulders", "biceps", "triceps", "legs", "glutes", "core", "calves", "forearms", "full_body", "cardio"
secondary_muscles :string[]        -- array of muscle names
equipment     :string              -- "barbell", "dumbbell", "cable", "machine", "bodyweight", "kettlebell", "resistance_band", "other"
instructions  :text
is_custom     :boolean default false
inserted_at   :utc_datetime
updated_at    :utc_datetime
```

### 4.2 Routines (`routines`)

```
id            :bigserial primary key
name          :string not null
notes         :text
inserted_at   :utc_datetime
updated_at    :utc_datetime
```

### 4.3 Routine Exercises (`routine_exercises`)

```
id            :bigserial primary key
routine_id    :references(:routines) on_delete: :delete_all
exercise_id   :references(:exercises) on_delete: :restrict
position      :integer not null        -- ordering within routine
target_sets   :integer default 3
inserted_at   :utc_datetime
updated_at    :utc_datetime

index [:routine_id, :position]
```

### 4.4 Workouts (`workouts`)

```
id            :bigserial primary key
routine_id    :references(:routines) nullable -- nil if ad-hoc
name          :string                         -- defaults to routine name or "Ad-hoc Workout"
notes         :text
status        :string default "in_progress"   -- "in_progress" | "completed" | "discarded"
started_at    :utc_datetime not null
finished_at   :utc_datetime nullable
duration_seconds :integer                     -- computed on finish
total_volume  :decimal                        -- kg × reps summed
total_sets    :integer
total_reps    :integer
inserted_at   :utc_datetime
updated_at    :utc_datetime
```

### 4.5 Workout Exercises (`workout_exercises`)

```
id            :bigserial primary key
workout_id    :references(:workouts) on_delete: :delete_all
exercise_id   :references(:exercises) on_delete: :restrict
position      :integer not null
notes         :text
inserted_at   :utc_datetime
updated_at    :utc_datetime

index [:workout_id, :position]
```

### 4.6 Workout Sets (`workout_sets`)

```
id                  :bigserial primary key
workout_exercise_id :references(:workout_exercises) on_delete: :delete_all
set_number          :integer not null
set_type            :string default "normal"    -- "warmup" | "normal" | "drop"
weight              :decimal                    -- in kg always; convert for display
reps                :integer
rpe                 :decimal                    -- 1.0–10.0, optional
is_completed        :boolean default false
inserted_at         :utc_datetime
updated_at          :utc_datetime

index [:workout_exercise_id, :set_number]
```

### 4.7 Personal Records (`personal_records`)

```
id            :bigserial primary key
exercise_id   :references(:exercises) on_delete: :cascade
workout_set_id :references(:workout_sets) nullable
record_type   :string     -- "max_weight" | "max_reps" | "estimated_1rm" | "max_volume_set" | "max_volume_session"
value         :decimal not null
achieved_at   :utc_datetime not null
inserted_at   :utc_datetime
updated_at    :utc_datetime

index [:exercise_id, :record_type]
```

### 4.8 Relationships

```
Routine  has_many  RoutineExercises
Routine  has_many  Exercises (through RoutineExercises)
Workout  belongs_to  Routine (optional)
Workout  has_many  WorkoutExercises
WorkoutExercise  belongs_to  Exercise
WorkoutExercise  has_many  WorkoutSets
Exercise  has_many  WorkoutSets (through WorkoutExercises)
Exercise  has_many  PersonalRecords
```

---

## 5. Application Structure

```
lib/
├── phoenixgym/
│   ├── application.ex
│   ├── repo.ex
│   ├── mailer.ex
│   │
│   ├── exercises/                  # Exercise Library context
│   │   ├── exercises.ex            # context module (CRUD + search)
│   │   └── exercise.ex             # Ecto schema
│   │
│   ├── routines/                   # Routines context
│   │   ├── routines.ex             # context module
│   │   ├── routine.ex              # schema
│   │   └── routine_exercise.ex     # schema
│   │
│   ├── workouts/                   # Workout Tracking context
│   │   ├── workouts.ex             # context module
│   │   ├── workout.ex              # schema
│   │   ├── workout_exercise.ex     # schema
│   │   ├── workout_set.ex          # schema
│   │   └── workout_stats.ex        # PR computation, volume aggregation
│   │
│   └── records/                    # Personal Records context
│       ├── records.ex
│       └── personal_record.ex
│
├── phoenixgym_web/
│   ├── router.ex
│   ├── endpoint.ex
│   ├── telemetry.ex
│   ├── gettext.ex
│   │
│   ├── components/
│   │   ├── core_components.ex      # Phoenix defaults (keep)
│   │   ├── layouts.ex              # Root + app layouts
│   │   ├── layouts/
│   │   │   └── root.html.heex
│   │   └── gym_components.ex       # App-specific DaisyUI components
│   │
│   └── live/
│       ├── dashboard_live/
│       │   └── index.ex            # Home / Stats dashboard
│       │
│       ├── exercise_live/
│       │   ├── index.ex            # Exercise library list + search
│       │   ├── new.ex              # Add custom exercise
│       │   └── show.ex             # Exercise detail + PR history
│       │
│       ├── routine_live/
│       │   ├── index.ex            # Routines list
│       │   ├── new.ex              # Create routine
│       │   ├── edit.ex             # Edit routine (add/reorder/remove exercises)
│       │   └── show.ex             # Routine detail preview
│       │
│       ├── workout_live/
│       │   ├── active.ex           # *** Active workout session (main screen)
│       │   ├── history.ex          # Workout history list
│       │   └── show.ex             # Past workout detail
│       │
│       └── profile_live/
│           └── index.ex            # Settings, unit preference, theme
│
priv/
└── repo/
    ├── migrations/
    │   ├── 001_create_exercises.exs
    │   ├── 002_create_routines.exs
    │   ├── 003_create_routine_exercises.exs
    │   ├── 004_create_workouts.exs
    │   ├── 005_create_workout_exercises.exs
    │   ├── 006_create_workout_sets.exs
    │   └── 007_create_personal_records.exs
    └── seeds.exs                   # 200+ exercises seed data
```

---

## 6. UI / Navigation Design

### 6.1 Bottom Tab Bar (Mobile-First)

Identical to Hevy's 5-tab bottom navigation. Fixed at the bottom on all screens.

```
┌──────────────────────────────────┐
│           Content Area           │
│                                  │
│                                  │
└──────────────────────────────────┘
┌────┬────┬────┬────┬────┐
│ 🏠 │ 📋 │ ▶️  │ 📊 │ 👤 │
│Home│Rout│Wkt │Hist│Prof│
└────┴────┴────┴────┴────┘
```

Tabs:
1. **Home** (`/`) — Dashboard with stats and recent activity
2. **Routines** (`/routines`) — Manage workout routines
3. **Workout** (`/workout/active`) — Start/continue workout (center CTA)
4. **History** (`/workout/history`) — Past workouts
5. **Profile** (`/profile`) — Settings

The center tab (Workout) uses the DaisyUI `btn-circle btn-primary` style, larger and elevated, like Hevy's play button.

### 6.2 App Layout

```
┌────────────────────────────┐
│  ← Back    Title    Action │  ← sticky top bar (per-page)
├────────────────────────────┤
│                            │
│       Scrollable           │
│       Content              │
│                            │
├────────────────────────────┤
│   Tab Bar (always visible) │
└────────────────────────────┘
```

- Root layout sets `h-screen flex flex-col` with the bottom nav fixed
- Content area is `flex-1 overflow-y-auto pb-20` (padding clears tab bar)
- No desktop sidebar — pure mobile layout, scales gracefully on desktop as a centered column (`max-w-lg mx-auto`)

### 6.3 Color & Theme

Using DaisyUI themes already configured in `app.css`:
- **Light theme**: Clean white/gray background, primary accent color
- **Dark theme**: Dark gray background, same accent
- Theme toggle available in Profile

### 6.4 Key Screen Layouts

#### Active Workout Screen

```
┌────────────────────────────┐
│ ✕  Workout  00:14:32  Done │  ← sticky header with timer
├────────────────────────────┤
│ ⏱ Rest: 1:45 ████░░░ Skip │  ← rest timer (conditionally shown)
├────────────────────────────┤
│ [Workout Notes...]         │
│                            │
│ ─── Bench Press ───────── │
│ chest · barbell            │
│ Last: 60kg×10  65kg×8      │  ← previous session reference
│                            │
│  #  Type  kg    Reps  ✓   │
│  W   W   40    12    ☐    │
│  1   N   60    10    ✓    │  ← completed (green row)
│  2   N   65     8    ☐    │
│ [+ Add Set]                │
│                            │
│ ─── Squat ──────────────  │
│  ...                       │
│                            │
│ [+ Add Exercise]           │
└────────────────────────────┘
```

#### Routine Edit Screen

```
┌────────────────────────────┐
│ ✕   Edit Routine    Save  │
├────────────────────────────┤
│ Name: [Push Day A      ]   │
│ Notes: [Optional...    ]   │
│                            │
│ ─── Exercises ──────────  │
│ ≡  Bench Press     3 sets │
│ ≡  Incline DB      3 sets │
│ ≡  Cable Fly       4 sets │
│                            │
│ [+ Add Exercise]           │
└────────────────────────────┘
```

---

## 7. Implementation Phases

### Phase 1 — Foundation & Data Layer

**Goal**: Database schema, seed data, contexts, core navigation shell.

Tasks:
- [ ] Create all 7 migrations
- [ ] Define all Ecto schemas with changesets and associations
- [ ] Create all context modules (exercises, routines, workouts, records)
- [ ] Seed 200+ exercises into the database
- [ ] Build the app shell: root layout with bottom tab bar navigation
- [ ] Create placeholder LiveViews for all 5 tabs
- [ ] Configure router with all LiveView routes

### Phase 2 — Exercise Library

**Goal**: Browse, search, filter, and create custom exercises.

Tasks:
- [ ] Exercise list LiveView with search (by name) and filter (muscle, equipment, category) using `phx-change` on form
- [ ] Exercise detail modal/page showing PR history for that exercise
- [ ] "Add Custom Exercise" form LiveView
- [ ] Exercise picker component (reused in routine builder and active workout)
- [ ] Muscle group and equipment badge components

### Phase 3 — Routine Builder

**Goal**: Full CRUD for routines with exercise management.

Tasks:
- [ ] Routine list with cards (name, exercise count, last used)
- [ ] Create routine LiveView (name + notes form)
- [ ] Routine edit LiveView:
  - Add exercises via exercise picker modal
  - Set target sets per exercise (inline number input)
  - Reorder exercises (up/down buttons)
  - Remove exercises
- [ ] Routine show/preview page
- [ ] Duplicate routine action
- [ ] Delete routine with confirmation

### Phase 4 — Active Workout (Core Feature)

**Goal**: Real-time workout logging with full Hevy-like UX.

Tasks:
- [ ] Workout LiveView state machine: `idle → in_progress → completed`
- [ ] Persist in-progress workout to DB immediately (crash recovery)
- [ ] "Start Workout" button: from routine (pre-populate) or blank
- [ ] Active workout screen:
  - Elapsed timer (JS hook updating every second via `pushEvent`)
  - Exercise sections with collapsible headers
  - Set rows: type selector, weight input, reps input, RPE (optional), complete checkbox
  - **Last session data**: query previous workout's sets for same exercise, display above current sets
  - Add set button (inserts new row at bottom)
  - Remove set (swipe or × button)
  - Set type toggle: W (warmup) / N (normal) / D (drop)
  - Completed set row turns green (`bg-success/20`)
- [ ] Rest timer: auto-start on set completion, configurable duration, countdown display, skip button
- [ ] Add exercise mid-workout (opens exercise picker modal)
- [ ] Reorder exercises within workout
- [ ] Finish workout: compute totals, mark PRs, save, redirect to workout detail
- [ ] Discard workout with confirmation modal

### Phase 5 — History & Workout Detail

**Goal**: View past sessions.

Tasks:
- [ ] Workout history list with infinite scroll or pagination (using LiveView streams)
- [ ] Workout detail view: full exercise/set breakdown, volume, duration
- [ ] PR highlights within workout detail (star icon on PR sets)
- [ ] Delete workout (with confirmation)

### Phase 6 — Personal Records & Stats

**Goal**: Automatic PR tracking and dashboard charts.

Tasks:
- [ ] PR computation hook on workout completion (WorkoutStats context)
  - Compare against existing PRs per exercise
  - Create new PersonalRecord rows when beaten
- [ ] PR display on exercise detail page (all-time bests table)
- [ ] Dashboard LiveView:
  - Weekly volume bar chart (SVG or simple CSS bars)
  - Workouts this week / this month counters
  - Top muscle groups (computed from recent workouts)
  - Recent PRs list
  - Streak counter

### Phase 7 — Profile & Settings

**Goal**: User preferences.

Tasks:
- [ ] Profile LiveView:
  - Display name input
  - Unit toggle: kg / lbs (stored in session/ETS)
  - Theme toggle (light / dark / system)
- [ ] Unit conversion applied globally: all weight inputs and displays convert based on preference

### Phase 8 — Polish & PWA

**Goal**: Production-ready mobile experience.

Tasks:
- [ ] Add PWA manifest (`priv/static/manifest.json`) for "Add to Home Screen"
- [ ] Service worker for offline support (exercise library, active workout)
- [ ] Add loading skeletons (DaisyUI `skeleton` class)
- [ ] Empty state illustrations for lists
- [ ] Error boundaries and flash messages
- [ ] Keyboard navigation improvements
- [ ] Optimize queries (add indexes, avoid N+1 with preloads)
- [ ] Mobile Safari scroll and input quirks fixes

---

## 8. Page-by-Page Breakdown

### 8.1 Dashboard (`/`)

**LiveView**: `DashboardLive.Index`

Sections:
- **Quick Start Card**: "Start Empty Workout" button + list of 3 most recent routines as quick-start buttons
- **This Week**: mini stat cards (workouts done, total volume, total sets)
- **Weekly Volume Chart**: 8-week bar chart using pure CSS/SVG
- **Recent Workouts**: last 3 workouts as cards
- **Recent PRs**: last 5 PR badges (exercise name + record type + value)

### 8.2 Exercise Library (`/exercises`)

**LiveView**: `ExerciseLive.Index`

- Top search bar with live filtering (`phx-change` debounced 200ms)
- Filter chips row: muscle group pills (horizontal scroll)
- Equipment filter dropdown
- Results list: each row has exercise name, primary muscle badge, equipment icon, chevron
- FAB (Floating Action Button): "+ Custom Exercise" (bottom-right, above tab bar)
- Tap row → `ExerciseLive.Show` (slide-up modal on mobile)

**LiveView**: `ExerciseLive.Show` (modal)
- Exercise name + category + muscle badges
- Instructions text
- Personal Records section: table of PRs (max weight, estimated 1RM, etc.)
- Recent sets history: last 5 workouts using this exercise

**LiveView**: `ExerciseLive.New` (modal)
- Form: name, category select, primary muscle select, secondary muscles checkboxes, equipment select, instructions textarea
- Save → adds to library

### 8.3 Routines (`/routines`)

**LiveView**: `RoutineLive.Index`
- List of routines as cards (name, X exercises, last performed date)
- Empty state with "Create Your First Routine" CTA
- FAB: "+ New Routine"
- Long-press or swipe for delete/duplicate options (or action buttons on card)

**LiveView**: `RoutineLive.New` → inline form or modal
- Just: name + notes, then redirect to edit

**LiveView**: `RoutineLive.Edit`
- Routine name + notes inputs at top
- Exercise list with drag handles (≡ icon), each showing exercise name + `target_sets` stepper
- "Remove" button per exercise
- "+ Add Exercise" → opens `ExerciseLive.Index` as picker modal
- Save button in header

### 8.4 Active Workout (`/workout/active`)

**LiveView**: `WorkoutLive.Active`

State managed entirely in LiveView assigns:
```elixir
assigns: %{
  workout: %Workout{},           # persisted
  exercises: [                    # ordered list
    %{
      workout_exercise: %WorkoutExercise{},
      exercise: %Exercise{},
      sets: [%WorkoutSet{}, ...],
      previous_sets: [%WorkoutSet{}, ...]  # from last session
    }
  ],
  elapsed_seconds: 0,            # updated by JS hook
  rest_timer: nil | %{seconds_remaining: int, total: int},
  adding_exercise: false          # show exercise picker modal
}
```

JS Hooks:
- `WorkoutTimer`: sends `tick` event every second → LiveView increments `elapsed_seconds`
- `RestTimer`: countdown timer after set completion
- `AutoScroll`: scrolls to newly added set input

Key Events:
- `add_set` — adds WorkoutSet to DB and assigns
- `remove_set`
- `update_set` — debounced weight/reps input updates
- `toggle_set_complete` — marks complete, triggers rest timer, checks PR
- `add_exercise` — opens picker
- `finish_workout` — computes totals, redirects to show
- `discard_workout`

### 8.5 Workout History (`/workout/history`)

**LiveView**: `WorkoutLive.History`

- Stream-based list of completed workouts
- Each card: date, name, duration, volume, top 3 exercises
- Infinite scroll with `phx-viewport-bottom` or paginated "Load More"

### 8.6 Workout Detail (`/workout/:id`)

**LiveView**: `WorkoutLive.Show`

- Header: name, date, duration, volume badges
- Per exercise section: sets table (type | weight | reps | RPE | PR★)
- Delete workout button with confirmation

### 8.7 Profile (`/profile`)

**LiveView**: `ProfileLive.Index`

- Display name input
- Unit toggle (kg / lbs) — DaisyUI `toggle`
- Theme switcher
- App version

---

## 9. Component Library

All components in `lib/phoenixgym_web/components/gym_components.ex` using DaisyUI classes:

### Defined Components

```elixir
# Bottom navigation bar
def bottom_nav(assigns)

# Exercise row for lists
def exercise_row(assigns)           # name, muscle badge, equipment

# Muscle group badge
def muscle_badge(assigns)           # colored badge by muscle group

# Set row in active workout
def set_row(assigns)                # set_number, type, weight_input, reps_input, complete_checkbox

# Previous sets reference display
def previous_sets(assigns)          # compact display of last session's sets

# Rest timer bar
def rest_timer(assigns)             # progress bar + countdown + skip

# Workout stat card
def stat_card(assigns)              # icon, value, label

# PR badge
def pr_badge(assigns)               # record_type, value, achieved_at

# Volume bar chart
def volume_chart(assigns)           # list of {week_label, volume} tuples → SVG bars

# Exercise picker modal
def exercise_picker(assigns)        # searchable list, fires select event

# Confirm modal
def confirm_modal(assigns)          # title, message, confirm_event, cancel_event

# Routine card
def routine_card(assigns)           # name, exercise_count, last_used

# Workout card (history)
def workout_card(assigns)           # date, name, duration, volume
```

---

## 10. State Management Strategy

### Active Workout Persistence Strategy

To avoid data loss if the browser closes or the server restarts during a workout:

1. **Immediate DB writes**: Every set update is persisted to the DB via Ecto immediately (debounced 500ms for text inputs, immediate for toggle actions).
2. **In-progress detection**: On app load, query for any `workouts` with `status = "in_progress"`. If found, redirect to `/workout/active` with a "Resume workout?" banner.
3. **LiveView crash recovery**: If the LiveView process crashes, it re-mounts and reloads state from the DB.

### Unit Preference

- Stored in Phoenix session (server-side) or `localStorage` (client-side via JS hook)
- All weights stored in **kg** in DB always
- Conversion applied at render time based on user preference
- Conversion factor: `1 kg = 2.20462 lbs`

### Previous Sets Query

When loading an active workout exercise, fetch the most recent completed `WorkoutExercise` for the same `exercise_id` (excluding current workout):

```elixir
def get_previous_sets(exercise_id, current_workout_id) do
  from(ws in WorkoutSet,
    join: we in WorkoutExercise, on: we.id == ws.workout_exercise_id,
    join: w in Workout, on: w.id == we.workout_id,
    where: we.exercise_id == ^exercise_id,
    where: w.id != ^current_workout_id,
    where: w.status == "completed",
    order_by: [desc: w.finished_at],
    limit: 10
  )
  |> Repo.all()
end
```

---

## 11. Seeding the Exercise Library

`priv/repo/seeds.exs` will insert ~200 exercises covering:

### Categories & Examples

| Category | Examples |
|---|---|
| **Chest** | Barbell Bench Press, Incline Dumbbell Press, Cable Fly, Dips, Push-Up, Pec Deck |
| **Back** | Barbell Row, Pull-Up, Lat Pulldown, Seated Cable Row, T-Bar Row, Deadlift |
| **Shoulders** | Overhead Press, Lateral Raise, Front Raise, Face Pull, Arnold Press |
| **Biceps** | Barbell Curl, Dumbbell Curl, Hammer Curl, Preacher Curl, Cable Curl |
| **Triceps** | Skull Crusher, Tricep Pushdown, Close-Grip Bench, Overhead Tricep Extension, Dips |
| **Legs** | Squat, Leg Press, Romanian Deadlift, Leg Curl, Leg Extension, Hack Squat |
| **Glutes** | Hip Thrust, Glute Bridge, Cable Kickback, Bulgarian Split Squat |
| **Calves** | Standing Calf Raise, Seated Calf Raise, Donkey Calf Raise |
| **Core** | Plank, Crunch, Hanging Leg Raise, Ab Wheel, Cable Crunch, Russian Twist |
| **Cardio** | Treadmill, Elliptical, Rowing Machine, Jump Rope, Cycling, Stair Climber |
| **Olympic** | Clean & Jerk, Snatch, Power Clean, Push Press |
| **Full Body** | Burpee, Turkish Get-Up, Battle Ropes, Box Jump |

Each exercise seed entry includes:
- `name`, `category`, `primary_muscle`, `equipment`, `is_custom: false`

---

## Implementation Notes

### File Naming Conventions

- LiveViews: `lib/phoenixgym_web/live/<context>_live/<action>.ex`
- Templates: co-located in same file (render/1 function) or `<action>.html.heex`
- Contexts: `lib/phoenixgym/<context>/<context>.ex` (the module name matches the directory)

### Router Organization

```elixir
scope "/", PhoenixgymWeb do
  pipe_through :browser

  # Dashboard
  live "/", DashboardLive.Index, :index

  # Exercises
  live "/exercises", ExerciseLive.Index, :index
  live "/exercises/new", ExerciseLive.Index, :new
  live "/exercises/:id", ExerciseLive.Show, :show

  # Routines
  live "/routines", RoutineLive.Index, :index
  live "/routines/new", RoutineLive.Index, :new
  live "/routines/:id", RoutineLive.Show, :show
  live "/routines/:id/edit", RoutineLive.Edit, :edit

  # Workouts
  live "/workout/active", WorkoutLive.Active, :index
  live "/workout/history", WorkoutLive.History, :index
  live "/workout/:id", WorkoutLive.Show, :show

  # Profile
  live "/profile", ProfileLive.Index, :index
end
```

### Key DaisyUI Components Used

- `navbar` + `btm-nav` — top bar + bottom navigation
- `card` — workout/routine cards
- `table` — set rows in active workout and detail view
- `modal` — exercise picker, confirm dialogs
- `badge` — muscle groups, set types, PRs
- `input`, `select`, `textarea` — all form fields
- `btn` — all buttons
- `progress` — rest timer bar
- `skeleton` — loading states
- `alert` — flash messages
- `tabs` — filter tabs in exercise library
- `stats` — dashboard stat cards
- `drawer` — potential side sheet for exercise picker on larger screens
- `toggle` — unit preference, theme toggle
- `countdown` — rest timer digits
- `radial-progress` — rest timer circular indicator (alternative)

### Performance Considerations

- Use LiveView **streams** for all list views (workout history, exercise list) to avoid re-rendering full lists
- Debounce weight/reps text inputs 500ms before persisting
- Index on `workout_exercises(workout_id, position)` and `workout_sets(workout_exercise_id, set_number)` for fast lookups
- Preload all associations in a single query when loading active workout
- Cache exercise list in LiveView assigns (exercises rarely change)

---

*End of Implementation Plan*
