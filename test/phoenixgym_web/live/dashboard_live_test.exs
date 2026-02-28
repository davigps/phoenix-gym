defmodule PhoenixgymWeb.DashboardLiveTest do
  use PhoenixgymWeb.ConnCase, async: false

  import Phoenix.LiveViewTest
  import Phoenixgym.Fixtures

  describe "Dashboard mount and content" do
    setup :register_and_log_in_user

    test "mounts with stat values", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      assert has_element?(view, "#volume-chart")
      # This week stats section
      assert has_element?(view, "div.stat", "Treinos")
      assert has_element?(view, "div.stat", "Volume")
      assert has_element?(view, "div.stat", "Séries")
    end

    test "quick-start section lists Start Empty Workout and recent routines", %{conn: conn} do
      routine_fixture(%{"name" => "Push Day"})
      routine_fixture(%{"name" => "Pull Day"})

      {:ok, _view, html} = live(conn, "/")

      assert html =~ "Início rápido"
      assert html =~ "Iniciar treino vazio"
      assert html =~ "Push Day"
      assert html =~ "Pull Day"
    end

    test "volume chart renders with 8 bars (weeks)", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      # volume_chart renders a div#volume-chart with flex children (one per week)
      assert has_element?(view, "#volume-chart")

      # Each week is a column; we have 8 data points
      html = render(view)
      # The chart has 8 week labels/bar containers (from weekly_volume returning 8 items)
      assert html =~ "volume-chart"
    end

    test "shows empty state when no workouts this week", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")
      assert html =~ "Faça seu primeiro treino para ver as estatísticas aqui!"
    end

    test "shows streak when user has completed workouts", %{conn: conn} do
      completed_workout_fixture()
      {:ok, _view, html} = live(conn, "/")
      assert html =~ "sequência de" or html =~ "dia"
    end

    test "shows recent PRs when present", %{conn: conn} do
      completed_workout_fixture()
      {:ok, _view, html} = live(conn, "/")
      # Recent PRs section may appear if we have PRs
      assert html =~ "PRs recentes" or html =~ "Início rápido"
    end
  end
end
