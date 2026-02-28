defmodule PhoenixgymWeb.ProfileLiveTest do
  use PhoenixgymWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  alias Phoenixgym.Workouts
  import Phoenixgym.Fixtures

  describe "ProfileLive.Index" do
    test "mounts with default unit kg when session has no unit", %{conn: conn} do
      {:ok, view, html} = live(conn, "/profile")

      assert html =~ "Profile"
      assert html =~ "Units"
      assert has_element?(view, "a[href*='set_unit'][href*='unit=kg']")
    end

    test "unit toggle persists to session and re-mounts with saved preference", %{conn: conn} do
      conn = get(conn, "/profile/set_unit?unit=lbs")
      assert redirected_to(conn) == "/profile"

      # Recycle conn so the session cookie is sent on the next request
      conn = recycle(conn)
      {:ok, _view, html} = live(conn, "/profile")

      # Sample weight display: 100 kg in lbs is 220.5 lbs
      assert html =~ "220.5"
      assert html =~ "lbs"
    end

    test "switching to lbs re-renders sample weight using converted display", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/profile")
      assert html =~ "100.0 kg"

      conn = get(conn, "/profile/set_unit?unit=lbs")
      conn = recycle(conn)
      {:ok, _view, html} = live(conn, "/profile")
      assert html =~ "220.5"
      assert html =~ "lbs"
    end

    test "display name input is present", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/profile")
      assert has_element?(view, "input[name='display_name']")
    end
  end

  describe "cross-LiveView unit preference" do
    @moduletag :async_false
    test "unit set to lbs in profile shows lbs labels and converted weights in active workout", %{
      conn: conn
    } do
      exercise = exercise_fixture()
      {:ok, workout} = Workouts.start_workout(%{})
      pos = Workouts.next_exercise_position(workout.id)
      {:ok, we} = Workouts.create_workout_exercise(workout.id, exercise.id, pos)

      Workouts.create_workout_set(we.id, 1, %{
        weight: Decimal.new("100"),
        reps: 5,
        set_type: "normal"
      })

      # Set unit to lbs via controller and recycle
      conn = get(conn, "/profile/set_unit?unit=lbs")
      conn = recycle(conn)

      # Open active workout (resumes in-progress)
      {:ok, _view, html} = live(conn, "/workout/active")

      # Weight column header should show lbs
      assert html =~ "lbs"
      # Previously stored 100 kg should display as 220.5 lbs
      assert html =~ "220.5"
    end
  end
end
