defmodule PhoenixgymWeb.WorkoutFlowIntegrationTest do
  @moduledoc """
  End-to-end flow: seed data → start workout from routine → add set →
  complete set → add exercise mid-workout → finish workout →
  verify history shows the workout → verify PR was recorded.
  """
  use PhoenixgymWeb.ConnCase, async: false

  import Phoenix.LiveViewTest
  import Phoenixgym.Fixtures

  alias Phoenixgym.Workouts
  alias Phoenixgym.Routines
  alias Phoenixgym.Records

  describe "full workout flow from routine to history and PR" do
    test "complete flow: start from routine, add set, complete set, add exercise, finish; history and PR updated",
         %{
           conn: conn
         } do
      # Build routine with one exercise
      ex1 = exercise_fixture(%{"name" => "E2E Bench #{System.unique_integer()}"})
      routine = routine_fixture(%{"name" => "E2E Routine #{System.unique_integer()}"})
      {:ok, re1} = Routines.add_exercise_to_routine(routine.id, ex1.id)
      Routines.update_routine_exercise(re1, %{target_sets: 2})
      routine = Routines.get_routine!(routine.id)

      # Start workout from routine
      {:ok, view, html} = live(conn, "/workout/active?from_routine=#{routine.id}")

      assert html =~ ex1.name

      # Add a set to the first exercise
      workout = Workouts.get_in_progress_workout()
      workout = Workouts.get_workout!(workout.id)
      we = hd(workout.workout_exercises)

      view
      |> element("button[phx-click='add_set'][phx-value-workout-exercise-id='#{we.id}']")
      |> render_click()

      # Reload workout to get the new set, then complete it via UI (weight, reps, checkbox)
      workout = Workouts.get_workout!(workout.id)
      set = workout.workout_exercises |> hd() |> Map.fetch!(:workout_sets) |> hd()

      view
      |> element(
        "input[phx-blur='update_set'][phx-value-id='#{set.id}'][phx-value-field='weight']"
      )
      |> render_blur(%{"value" => "100"})

      view
      |> element("input[phx-blur='update_set'][phx-value-id='#{set.id}'][phx-value-field='reps']")
      |> render_blur(%{"value" => "5"})

      view
      |> element("input[type='checkbox'][phx-click='toggle_complete'][phx-value-id='#{set.id}']")
      |> render_click()

      # Add another exercise mid-workout
      ex2 = exercise_fixture(%{"name" => "E2E Squat #{System.unique_integer()}"})
      view |> element("button[phx-click='show_picker']") |> render_click()

      view
      |> element("button[phx-click='add_exercise'][phx-value-id='#{ex2.id}']")
      |> render_click()

      # Finish workout
      result = view |> element("button[phx-click='finish']") |> render_click()
      assert {:error, {:live_redirect, %{to: path}}} = result
      assert path =~ ~r|/workout/\d+|

      # Open history and verify the workout appears
      {:ok, _history_view, history_html} = live(conn, "/workout/history")
      assert history_html =~ routine.name

      # Verify workout is in completed list
      completed = Workouts.list_completed_workouts(limit: 5)
      workout_names = Enum.map(completed, & &1.name)
      assert routine.name in workout_names

      # Verify PR was recorded for the exercise we completed with weight
      prs = Records.list_records_for_exercise(ex1.id)
      assert length(prs) >= 1
      max_weight_pr = Enum.find(prs, fn pr -> pr.record_type == "max_weight" end)
      assert max_weight_pr != nil
      assert Decimal.equal?(max_weight_pr.value, Decimal.new("100.0"))
    end
  end
end
