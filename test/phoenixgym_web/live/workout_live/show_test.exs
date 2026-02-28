defmodule PhoenixgymWeb.WorkoutLive.ShowTest do
  use PhoenixgymWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Phoenixgym.Fixtures

  alias Phoenixgym.Workouts
  alias Phoenixgym.Records

  describe "workout detail" do
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
      Records.compute_and_save_prs(workout)
      workout = Workouts.get_workout!(workout.id)

      {:ok, _view, html} = live(conn, "/workout/#{workout.id}")

      assert html =~ "pr-star" or html =~ "hero-star" or html =~ "PR"
    end

    test "delete button shows confirmation modal", %{conn: conn} do
      %{workout: workout} = completed_workout_fixture()

      {:ok, view, _html} = live(conn, "/workout/#{workout.id}")
      html = view |> element("button[phx-click='delete']") |> render_click()

      assert html =~ "confirm-delete-modal"
      assert html =~ "Delete Workout"
      assert html =~ "Are you sure"
    end

    test "confirming delete removes workout and redirects to history", %{conn: conn} do
      %{workout: workout} = completed_workout_fixture()
      workout_id = workout.id

      {:ok, view, _html} = live(conn, "/workout/#{workout_id}")
      view |> element("button[phx-click='delete']") |> render_click()
      view |> element("#confirm-delete-btn") |> render_click()

      assert_redirect(view, "/workout/history")
      assert_raise Ecto.NoResultsError, fn -> Workouts.get_workout!(workout_id) end
    end

    test "cancelling delete keeps workout", %{conn: conn} do
      %{workout: workout} = completed_workout_fixture()

      {:ok, view, _html} = live(conn, "/workout/#{workout.id}")
      view |> element("button[phx-click='delete']") |> render_click()
      view |> element("#cancel-delete-btn") |> render_click()

      html = render(view)
      assert html =~ (workout.name || "Workout")
      assert Workouts.get_workout!(workout.id).id == workout.id
    end
  end
end
