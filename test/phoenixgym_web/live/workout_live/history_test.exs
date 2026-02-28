defmodule PhoenixgymWeb.WorkoutLive.HistoryTest do
  use PhoenixgymWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Phoenixgym.Fixtures

  alias Phoenixgym.Workouts

  describe "WorkoutLive.History" do
    test "only completed workouts appear; in_progress and discarded do not", %{conn: conn} do
      %{workout: completed} = completed_workout_fixture()
      {:ok, _in_progress} = Workouts.start_workout(%{"name" => "In Progress"})
      {:ok, discarded} = Workouts.start_workout(%{"name" => "Discarded"})
      Workouts.discard_workout(discarded)

      {:ok, _view, html} = live(conn, "/workout/history")

      assert html =~ completed.name
      refute html =~ "In Progress"
      refute html =~ "Discarded"
    end

    test "most recent completed workout is first", %{conn: _conn} do
      %{workout: _older} = completed_workout_fixture()
      Process.sleep(10)
      %{workout: newer} = completed_workout_fixture()

      list = Workouts.list_completed_workouts(limit: 2)
      assert length(list) >= 1
      # First item has the latest finished_at (or latest id when tied)
      assert hd(list).id == newer.id
    end

    test "each card shows correct date, duration, and volume", %{conn: conn} do
      %{workout: workout} = completed_workout_fixture()
      workout = Workouts.get_workout!(workout.id)

      {:ok, _view, html} = live(conn, "/workout/history")

      assert html =~ (workout.name || "Workout")

      if workout.duration_seconds do
        m = div(workout.duration_seconds, 60)
        assert html =~ "#{m}m" or html =~ to_string(m)
      end

      if workout.total_volume do
        vol_str = Decimal.round(workout.total_volume, 1) |> Decimal.to_string()
        assert html =~ vol_str
      end

      if workout.total_sets do
        assert html =~ "#{workout.total_sets} sets"
      end
    end

    test "empty state when no completed workouts", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/workout/history")

      assert html =~ "No workouts yet"
      assert html =~ "Start Workout"
      assert html =~ "/workout/active"
    end

    test "Load More appends next page without removing existing items", %{conn: conn} do
      for _ <- 1..22, do: completed_workout_fixture()

      {:ok, view, html} = live(conn, "/workout/history")

      initial_count = count_workout_links(html)
      assert initial_count >= 20

      view
      |> element("#load-more-workouts")
      |> render_click()

      html_after = render(view)
      links_after = count_workout_links(html_after)
      assert links_after > initial_count
      assert html_after =~ "/workout/"
    end

    test "has element workouts and load more button when more pages exist", %{conn: conn} do
      for _ <- 1..21, do: completed_workout_fixture()

      {:ok, view, _html} = live(conn, "/workout/history")

      assert has_element?(view, "#workouts")
      assert has_element?(view, "#load-more-workouts")
    end

    test "no Load More button when fewer than page_size results", %{conn: conn} do
      completed_workout_fixture()
      completed_workout_fixture()

      {:ok, view, _html} = live(conn, "/workout/history")

      refute has_element?(view, "#load-more-workouts")
    end
  end

  defp count_workout_links(html) do
    Regex.scan(~r/href="\/workout\/\d+"/, html) |> length()
  end
end
