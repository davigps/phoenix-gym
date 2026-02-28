defmodule PhoenixgymWeb.WorkoutLive.ShowTest do
  use PhoenixgymWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Phoenixgym.Fixtures

  alias Phoenixgym.Workouts
  alias Phoenixgym.Records

  describe "WorkoutLive.Show" do
    test "all exercises and sets rendered", %{conn: conn} do
      %{workout: workout, exercise: exercise, set: set} = completed_workout_fixture()
      workout = Workouts.get_workout!(workout.id)

      {:ok, _view, html} = live(conn, "/workout/#{workout.id}")

      assert html =~ (workout.name || "Workout")
      assert html =~ exercise.name
      assert html =~ to_string(set.set_number)
      assert html =~ Decimal.to_string(Decimal.round(set.weight, 1))
      assert html =~ to_string(set.reps)
    end

    test "PR-flagged sets show star indicator", %{conn: conn} do
      %{workout: workout, set: _set, exercise: _exercise} = completed_workout_fixture()
      workout = Workouts.get_workout!(workout.id)
      Records.compute_and_save_prs(workout)

      {:ok, _view, html} = live(conn, "/workout/#{workout.id}")

      assert html =~ "hero-star"
      assert html =~ "Personal Record"
      assert html =~ "pr-star"
    end

    test "no star when workout has no PRs", %{conn: conn} do
      %{workout: workout} = completed_workout_fixture()
      # Do not call compute_and_save_prs; no PRs for this workout's sets

      {:ok, view, html} = live(conn, "/workout/#{workout.id}")

      assert has_element?(view, "#delete-workout-btn")
      refute html =~ "pr-star"
    end

    test "delete button shows confirmation modal", %{conn: conn} do
      %{workout: workout} = completed_workout_fixture()

      {:ok, view, _html} = live(conn, "/workout/#{workout.id}")

      refute has_element?(view, "#confirm-delete-modal.modal-open")
      view |> element("#delete-workout-btn") |> render_click()
      assert has_element?(view, "#confirm-delete-modal")
      assert has_element?(view, "#confirm-delete-btn")
      assert has_element?(view, "#cancel-delete-btn")
    end

    test "confirming delete deletes workout and redirects to history", %{conn: conn} do
      %{workout: workout} = completed_workout_fixture()
      workout_id = workout.id

      {:ok, view, _html} = live(conn, "/workout/#{workout_id}")

      view |> element("#delete-workout-btn") |> render_click()

      assert {:error, {:live_redirect, %{to: "/workout/history"}}} =
               view |> element("#confirm-delete-btn") |> render_click()

      assert_raise Ecto.NoResultsError, fn ->
        Workouts.get_workout!(workout_id)
      end
    end

    test "cancel delete closes modal and keeps workout", %{conn: conn} do
      %{workout: workout} = completed_workout_fixture()

      {:ok, view, _html} = live(conn, "/workout/#{workout.id}")

      view |> element("#delete-workout-btn") |> render_click()
      assert has_element?(view, "#confirm-delete-modal")
      view |> element("#cancel-delete-btn") |> render_click()
      refute has_element?(view, "#confirm-delete-modal")
      assert Workouts.get_workout!(workout.id).id == workout.id
    end

    test "summary stats show duration, volume, sets", %{conn: conn} do
      %{workout: workout} = completed_workout_fixture()
      workout = Workouts.get_workout!(workout.id)

      {:ok, _view, html} = live(conn, "/workout/#{workout.id}")

      assert html =~ "Duration"
      assert html =~ "Volume"
      assert html =~ "Sets"

      if workout.duration_seconds do
        m = div(workout.duration_seconds, 60)
        assert html =~ "#{m}m" or html =~ to_string(m)
      end

      if workout.total_volume do
        vol_str = Decimal.round(workout.total_volume, 1) |> Decimal.to_string()
        assert html =~ vol_str
      end
    end
  end
end
