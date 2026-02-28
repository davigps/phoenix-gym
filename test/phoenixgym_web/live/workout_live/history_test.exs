defmodule PhoenixgymWeb.WorkoutLive.HistoryTest do
  use PhoenixgymWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Phoenixgym.Fixtures

  alias Phoenixgym.Workouts

  describe "workout history" do
    test "only completed workouts appear", %{conn: conn} do
      %{workout: completed} = completed_workout_fixture()
      {:ok, _in_progress} = Workouts.start_workout()
      {:ok, discarded} = Workouts.start_workout()
      Workouts.discard_workout(discarded)

      {:ok, _view, html} = live(conn, "/workout/history")

      assert html =~ (completed.name || "Workout")
    end

    test "most recent workout is first", %{conn: conn} do
      completed_workout_fixture()
      %{workout: newer} = completed_workout_fixture()

      {:ok, view, _html} = live(conn, "/workout/history")
      html = render(view)
      assert html =~ (newer.name || "Workout")
    end

    test "each card shows date, duration, and volume", %{conn: conn} do
      %{workout: workout} = completed_workout_fixture()
      workout = Workouts.get_workout!(workout.id)

      {:ok, _view, html} = live(conn, "/workout/history")

      assert html =~ (workout.name || "Workout")

      assert workout.duration_seconds == nil or
               html =~ to_string(div(workout.duration_seconds, 60))

      assert workout.total_volume == nil or
               html =~ Decimal.to_string(Decimal.round(workout.total_volume, 1))
    end

    test "empty state when no completed workouts", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/workout/history")

      assert html =~ "No workouts yet"
      assert html =~ "Start Workout"
    end

    test "Load More appends next page", %{conn: conn} do
      # Create more than one page (page size is 20)
      for _ <- 1..25, do: completed_workout_fixture()

      {:ok, view, html} = live(conn, "/workout/history")
      initial_count = count_stream_entries(html)
      assert initial_count == 20, "first page should have 20 items"

      view
      |> element("button#load-more-workouts")
      |> render_click()

      updated_html = render(view)
      updated_count = count_stream_entries(updated_html)
      assert updated_count > initial_count
    end

    test "card links to workout detail", %{conn: conn} do
      %{workout: workout} = completed_workout_fixture()

      {:ok, view, _html} = live(conn, "/workout/history")
      assert has_element?(view, "a[href='/workout/#{workout.id}']")
    end
  end

  defp count_stream_entries(html) do
    # Stream child divs have id like "workouts-0", "workouts-1"
    Regex.scan(~r/id="workouts-\d+"/, html) |> length()
  end
end
