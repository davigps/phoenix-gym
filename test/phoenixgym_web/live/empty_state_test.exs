defmodule PhoenixgymWeb.EmptyStateTest do
  @moduledoc """
  Phase 8: Empty state test — history with no workouts shows CTA;
  exercise library with no search results shows empty message.
  """
  use PhoenixgymWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "empty states" do
    test "history page with no workouts renders 'No workouts yet' CTA", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/workout/history")

      assert html =~ "No workouts yet"
      assert html =~ "Start Workout"
      assert html =~ "/workout/active"
    end

    test "exercise library with no search results renders 'No exercises found' message", %{
      conn: conn
    } do
      {:ok, view, _html} = live(conn, "/exercises")

      html =
        view
        |> element("form[phx-change='search']")
        |> render_change(%{"search" => "ZZZNoMatch999XXX"})

      assert html =~ "No exercises found"
    end
  end
end
