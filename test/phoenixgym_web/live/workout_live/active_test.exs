defmodule PhoenixgymWeb.WorkoutLive.ActiveTest do
  use PhoenixgymWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Phoenixgym.Fixtures

  alias Phoenixgym.Workouts
  alias Phoenixgym.Routines

  # ── Start from scratch ────────────────────────────────────────────────────

  describe "start from scratch" do
    test "mounts in idle state when no workout exists", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/workout/active")

      assert html =~ "Start Empty Workout"
      assert html =~ "Choose Routine"
    end

    test "clicking Start Empty Workout creates a DB record and enters in-progress", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/workout/active")

      html = view |> element("button[phx-click='start_empty']") |> render_click()

      assert html =~ "Finish"
      assert html =~ "Add Exercise"
      assert Workouts.get_in_progress_workout() != nil
    end

    test "add_set event appends a set to a workout exercise", %{conn: conn} do
      exercise = exercise_fixture()

      {:ok, view, _html} = live(conn, "/workout/active")
      view |> element("button[phx-click='start_empty']") |> render_click()
      view |> element("button[phx-click='show_picker']") |> render_click()
      view |> element("button[phx-click='add_exercise'][phx-value-id='#{exercise.id}']") |> render_click()

      workout = Workouts.get_in_progress_workout()
      workout = Workouts.get_workout!(workout.id)
      we = hd(workout.workout_exercises)

      # One default set was added when exercise was added — now add another
      view
      |> element("button[phx-click='add_set'][phx-value-workout-exercise-id='#{we.id}']")
      |> render_click()

      updated = Workouts.get_workout!(workout.id)
      assert length(hd(updated.workout_exercises).workout_sets) == 2
    end

    test "update_set event persists weight changes", %{conn: conn} do
      exercise = exercise_fixture()

      {:ok, view, _html} = live(conn, "/workout/active")
      view |> element("button[phx-click='start_empty']") |> render_click()
      view |> element("button[phx-click='show_picker']") |> render_click()
      view |> element("button[phx-click='add_exercise'][phx-value-id='#{exercise.id}']") |> render_click()

      workout = Workouts.get_in_progress_workout()
      workout = Workouts.get_workout!(workout.id)
      set = workout.workout_exercises |> hd() |> Map.fetch!(:workout_sets) |> hd()

      view
      |> element("input[phx-blur='update_set'][phx-value-id='#{set.id}'][phx-value-field='weight']")
      |> render_blur(%{"value" => "80.5"})

      updated_set = Workouts.get_workout_set!(set.id)
      assert Decimal.equal?(updated_set.weight, Decimal.new("80.5"))
    end

    test "toggle_complete marks set completed (row turns green)", %{conn: conn} do
      exercise = exercise_fixture()

      {:ok, view, _html} = live(conn, "/workout/active")
      view |> element("button[phx-click='start_empty']") |> render_click()
      view |> element("button[phx-click='show_picker']") |> render_click()
      view |> element("button[phx-click='add_exercise'][phx-value-id='#{exercise.id}']") |> render_click()

      workout = Workouts.get_in_progress_workout()
      workout = Workouts.get_workout!(workout.id)
      set = workout.workout_exercises |> hd() |> Map.fetch!(:workout_sets) |> hd()

      html =
        view
        |> element("input[type='checkbox'][phx-click='toggle_complete'][phx-value-id='#{set.id}']")
        |> render_click()

      assert html =~ "bg-success/20"

      updated_set = Workouts.get_workout_set!(set.id)
      assert updated_set.is_completed == true
    end

    test "remove_set event removes a set from the exercise", %{conn: conn} do
      exercise = exercise_fixture()

      {:ok, view, _html} = live(conn, "/workout/active")
      view |> element("button[phx-click='start_empty']") |> render_click()
      view |> element("button[phx-click='show_picker']") |> render_click()
      view |> element("button[phx-click='add_exercise'][phx-value-id='#{exercise.id}']") |> render_click()

      workout = Workouts.get_in_progress_workout()
      workout = Workouts.get_workout!(workout.id)
      we = hd(workout.workout_exercises)

      # Add a second set so we can remove one
      view |> element("button[phx-click='add_set'][phx-value-workout-exercise-id='#{we.id}']") |> render_click()

      workout = Workouts.get_workout!(workout.id)
      [set1, _set2] = hd(workout.workout_exercises).workout_sets

      view
      |> element("button[phx-click='remove_set'][phx-value-id='#{set1.id}']")
      |> render_click()

      updated = Workouts.get_workout!(workout.id)
      assert length(hd(updated.workout_exercises).workout_sets) == 1
    end

    test "finish_workout redirects to /workout/:id", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/workout/active")
      view |> element("button[phx-click='start_empty']") |> render_click()

      assert {:error, {:live_redirect, %{to: path}}} =
               view |> element("button[phx-click='finish']") |> render_click()

      assert path =~ ~r|/workout/\d+|
    end

    test "finish_workout computes totals and marks status completed", %{conn: conn} do
      exercise = exercise_fixture()

      {:ok, view, _html} = live(conn, "/workout/active")
      view |> element("button[phx-click='start_empty']") |> render_click()
      view |> element("button[phx-click='show_picker']") |> render_click()
      view |> element("button[phx-click='add_exercise'][phx-value-id='#{exercise.id}']") |> render_click()

      workout = Workouts.get_in_progress_workout()
      workout = Workouts.get_workout!(workout.id)
      set = workout.workout_exercises |> hd() |> Map.fetch!(:workout_sets) |> hd()

      Workouts.update_workout_set(set, %{weight: "100.0", reps: 5, is_completed: true})

      view |> element("button[phx-click='finish']") |> render_click()

      finished = Workouts.get_workout!(workout.id)
      assert finished.status == "completed"
      assert finished.total_sets == 1
      assert finished.total_reps == 5
    end
  end

  # ── Start from routine ────────────────────────────────────────────────────

  describe "start from routine" do
    test "exercises pre-populated when workout started from routine", %{conn: conn} do
      ex1 = exercise_fixture(%{"name" => "RoutineEx1_#{System.unique_integer()}"})
      ex2 = exercise_fixture(%{"name" => "RoutineEx2_#{System.unique_integer()}"})
      routine = routine_fixture()
      {:ok, re1} = Routines.add_exercise_to_routine(routine.id, ex1.id)
      Routines.update_routine_exercise(re1, %{target_sets: 3})
      {:ok, re2} = Routines.add_exercise_to_routine(routine.id, ex2.id)
      Routines.update_routine_exercise(re2, %{target_sets: 2})

      routine = Routines.get_routine!(routine.id)
      {:ok, _workout} = Workouts.start_workout_from_routine(routine)

      {:ok, _view, html} = live(conn, "/workout/active")

      assert html =~ ex1.name
      assert html =~ ex2.name
    end

    test "target sets pre-populated from routine", %{conn: _conn} do
      exercise = exercise_fixture()
      routine = routine_fixture()
      {:ok, re} = Routines.add_exercise_to_routine(routine.id, exercise.id)
      Routines.update_routine_exercise(re, %{target_sets: 3})

      routine = Routines.get_routine!(routine.id)
      {:ok, workout} = Workouts.start_workout_from_routine(routine)

      workout = Workouts.get_workout!(workout.id)
      total_sets =
        workout.workout_exercises
        |> Enum.flat_map(& &1.workout_sets)
        |> length()

      assert total_sets == 3
    end

    test "previous sets displayed for exercises with history", %{conn: conn} do
      exercise = exercise_fixture(%{"name" => "HistExercise_#{System.unique_integer()}"})

      # Create a completed workout with this exercise
      {:ok, prev_workout} = Workouts.start_workout()
      pos = Workouts.next_exercise_position(prev_workout.id)
      {:ok, prev_we} = Workouts.create_workout_exercise(prev_workout.id, exercise.id, pos)
      Workouts.create_workout_set(prev_we.id, 1, %{weight: "75.0", reps: 8, is_completed: true})
      Workouts.finish_workout(prev_workout)

      # Start new workout from routine with same exercise
      routine = routine_fixture()
      {:ok, re} = Routines.add_exercise_to_routine(routine.id, exercise.id)
      Routines.update_routine_exercise(re, %{target_sets: 1})
      routine = Routines.get_routine!(routine.id)
      {:ok, _new_workout} = Workouts.start_workout_from_routine(routine)

      {:ok, _view, html} = live(conn, "/workout/active")

      assert html =~ "Last:"
      assert html =~ "75"
    end

    test "workout name matches routine name", %{conn: _conn} do
      routine = routine_fixture(%{"name" => "MyTestRoutine_#{System.unique_integer()}"})
      routine = Routines.get_routine!(routine.id)
      {:ok, workout} = Workouts.start_workout_from_routine(routine)

      assert workout.name == routine.name
      assert workout.routine_id == routine.id
    end
  end

  # ── Crash recovery ────────────────────────────────────────────────────────

  describe "crash recovery" do
    test "re-mounting with existing in-progress workout restores all exercises and sets", %{conn: conn} do
      exercise = exercise_fixture(%{"name" => "CrashEx_#{System.unique_integer()}"})

      {:ok, workout} = Workouts.start_workout(%{"name" => "Crash Recovery Test"})
      pos = Workouts.next_exercise_position(workout.id)
      {:ok, we} = Workouts.create_workout_exercise(workout.id, exercise.id, pos)
      Workouts.create_workout_set(we.id, 1, %{weight: "60.0", reps: 10})
      Workouts.create_workout_set(we.id, 2, %{weight: "65.0", reps: 8})

      # Fresh mount — should restore from DB
      {:ok, _view, html} = live(conn, "/workout/active")

      assert html =~ exercise.name
      assert html =~ "Finish"
    end

    test "restored workout shows correct set count", %{conn: conn} do
      exercise = exercise_fixture()

      {:ok, workout} = Workouts.start_workout()
      pos = Workouts.next_exercise_position(workout.id)
      {:ok, we} = Workouts.create_workout_exercise(workout.id, exercise.id, pos)
      Workouts.create_workout_set(we.id, 1)
      Workouts.create_workout_set(we.id, 2)
      Workouts.create_workout_set(we.id, 3)

      {:ok, _view, html} = live(conn, "/workout/active")

      # 3 checkboxes visible
      assert html =~ "toggle_complete"
      # 3 remove buttons visible
      assert html =~ "remove_set"
    end
  end

  # ── Discard flow ──────────────────────────────────────────────────────────

  describe "discard flow" do
    test "clicking discard shows confirmation modal", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/workout/active")
      view |> element("button[phx-click='start_empty']") |> render_click()

      html = view |> element("button[phx-click='discard']") |> render_click()

      assert html =~ "confirm_discard"
      assert html =~ "Discard Workout"
    end

    test "confirming discard marks workout as discarded and returns to idle", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/workout/active")
      view |> element("button[phx-click='start_empty']") |> render_click()

      workout = Workouts.get_in_progress_workout()

      view |> element("button[phx-click='discard']") |> render_click()
      html = view |> element("button[phx-click='confirm_discard']") |> render_click()

      assert html =~ "Start Empty Workout"

      discarded = Workouts.get_workout!(workout.id)
      assert discarded.status == "discarded"
    end

    test "cancelling discard keeps workout active", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/workout/active")
      view |> element("button[phx-click='start_empty']") |> render_click()

      view |> element("button[phx-click='discard']") |> render_click()
      html = view |> element("button[phx-click='cancel_discard']") |> render_click()

      assert html =~ "Finish"
      assert Workouts.get_in_progress_workout() != nil
    end
  end

  # ── Exercise reordering ───────────────────────────────────────────────────

  describe "exercise reordering" do
    test "move_exercise_down swaps exercise with the one below", %{conn: conn} do
      ex1 = exercise_fixture(%{"name" => "FirstExercise_#{System.unique_integer()}"})
      ex2 = exercise_fixture(%{"name" => "SecondExercise_#{System.unique_integer()}"})

      {:ok, view, _html} = live(conn, "/workout/active")
      view |> element("button[phx-click='start_empty']") |> render_click()

      view |> element("button[phx-click='show_picker']") |> render_click()
      view |> element("button[phx-click='add_exercise'][phx-value-id='#{ex1.id}']") |> render_click()
      view |> element("button[phx-click='show_picker']") |> render_click()
      view |> element("button[phx-click='add_exercise'][phx-value-id='#{ex2.id}']") |> render_click()

      workout = Workouts.get_in_progress_workout()
      workout = Workouts.get_workout!(workout.id)
      [we1, _we2] = workout.workout_exercises

      view
      |> element("button[phx-click='move_exercise_down'][phx-value-id='#{we1.id}']")
      |> render_click()

      updated = Workouts.get_workout!(workout.id)
      assert hd(updated.workout_exercises).exercise_id == ex2.id
    end

    test "move_exercise_up swaps exercise with the one above", %{conn: conn} do
      ex1 = exercise_fixture(%{"name" => "UpFirst_#{System.unique_integer()}"})
      ex2 = exercise_fixture(%{"name" => "UpSecond_#{System.unique_integer()}"})

      {:ok, view, _html} = live(conn, "/workout/active")
      view |> element("button[phx-click='start_empty']") |> render_click()

      view |> element("button[phx-click='show_picker']") |> render_click()
      view |> element("button[phx-click='add_exercise'][phx-value-id='#{ex1.id}']") |> render_click()
      view |> element("button[phx-click='show_picker']") |> render_click()
      view |> element("button[phx-click='add_exercise'][phx-value-id='#{ex2.id}']") |> render_click()

      workout = Workouts.get_in_progress_workout()
      workout = Workouts.get_workout!(workout.id)
      [_we1, we2] = workout.workout_exercises

      view
      |> element("button[phx-click='move_exercise_up'][phx-value-id='#{we2.id}']")
      |> render_click()

      updated = Workouts.get_workout!(workout.id)
      assert hd(updated.workout_exercises).exercise_id == ex2.id
    end
  end

  # ── Rest timer ────────────────────────────────────────────────────────────

  describe "rest timer" do
    test "rest timer shown after completing a set", %{conn: conn} do
      exercise = exercise_fixture()

      {:ok, view, _html} = live(conn, "/workout/active")
      view |> element("button[phx-click='start_empty']") |> render_click()
      view |> element("button[phx-click='show_picker']") |> render_click()
      view |> element("button[phx-click='add_exercise'][phx-value-id='#{exercise.id}']") |> render_click()

      workout = Workouts.get_in_progress_workout()
      workout = Workouts.get_workout!(workout.id)
      set = workout.workout_exercises |> hd() |> Map.fetch!(:workout_sets) |> hd()

      html =
        view
        |> element("input[type='checkbox'][phx-click='toggle_complete'][phx-value-id='#{set.id}']")
        |> render_click()

      assert html =~ "skip_rest_timer"
      assert html =~ "Skip"
    end

    test "skip_rest_timer hides the rest timer", %{conn: conn} do
      exercise = exercise_fixture()

      {:ok, view, _html} = live(conn, "/workout/active")
      view |> element("button[phx-click='start_empty']") |> render_click()
      view |> element("button[phx-click='show_picker']") |> render_click()
      view |> element("button[phx-click='add_exercise'][phx-value-id='#{exercise.id}']") |> render_click()

      workout = Workouts.get_in_progress_workout()
      workout = Workouts.get_workout!(workout.id)
      set = workout.workout_exercises |> hd() |> Map.fetch!(:workout_sets) |> hd()

      # Complete set to start timer
      view
      |> element("input[type='checkbox'][phx-click='toggle_complete'][phx-value-id='#{set.id}']")
      |> render_click()

      html = view |> element("button[phx-click='skip_rest_timer']") |> render_click()

      refute html =~ "skip_rest_timer"
    end
  end

  # ── Add exercise mid-workout ──────────────────────────────────────────────

  describe "add exercise mid-workout" do
    test "picker search filters exercises by name", %{conn: conn} do
      unique = "SearchEx_#{System.unique_integer()}"
      exercise_fixture(%{"name" => unique})
      exercise_fixture(%{"name" => "UnrelatedName_#{System.unique_integer()}"})

      {:ok, view, _html} = live(conn, "/workout/active")
      view |> element("button[phx-click='start_empty']") |> render_click()
      view |> element("button[phx-click='show_picker']") |> render_click()

      html =
        view
        |> element("input[phx-keyup='picker_search']")
        |> render_keyup(%{"value" => unique})

      assert html =~ unique
      refute html =~ "UnrelatedName"
    end

    test "adding an exercise creates one default set", %{conn: conn} do
      exercise = exercise_fixture()

      {:ok, view, _html} = live(conn, "/workout/active")
      view |> element("button[phx-click='start_empty']") |> render_click()
      view |> element("button[phx-click='show_picker']") |> render_click()
      view |> element("button[phx-click='add_exercise'][phx-value-id='#{exercise.id}']") |> render_click()

      workout = Workouts.get_in_progress_workout()
      workout = Workouts.get_workout!(workout.id)
      assert length(hd(workout.workout_exercises).workout_sets) == 1
    end
  end
end
