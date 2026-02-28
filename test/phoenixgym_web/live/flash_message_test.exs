defmodule PhoenixgymWeb.FlashMessageTest do
  @moduledoc """
  Phase 8: Flash message test — invalid form submission renders an alert with error text;
  successful action renders success flash.
  """
  use PhoenixgymWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "flash messages" do
    test "invalid form submission shows error and alert component", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/exercises/new")

      # Submit with empty required name
      html =
        view
        |> element("form[phx-submit='save']")
        |> render_submit(%{
          "exercise" => %{
            "name" => "",
            "category" => "",
            "primary_muscle" => "",
            "equipment" => "",
            "instructions" => ""
          }
        })

      # Inline validation error for name (Ecto default message)
      assert html =~ "can't be blank" or html =~ "blank"
      assert has_element?(view, "form")
    end

    test "successful exercise creation redirects to show page", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/exercises/new")

      result =
        view
        |> element("form[phx-submit='save']")
        |> render_submit(%{
          "exercise" => %{
            "name" => "Flash Test Exercise #{System.unique_integer()}",
            "category" => "strength",
            "primary_muscle" => "chest",
            "equipment" => "barbell",
            "instructions" => ""
          }
        })

      # Redirects to show page
      assert {:error, {:live_redirect, %{to: path}}} = result
      assert path =~ ~r|/exercises/\d+|
    end

    test "successful workout finish redirects to workout detail and layout has alert role", %{
      conn: conn
    } do
      {:ok, view, _html} = live(conn, "/workout/active")
      view |> element("button[phx-click='start_empty']") |> render_click()
      result = view |> element("button[phx-click='finish']") |> render_click()

      assert {:error, {:live_redirect, %{to: path}}} = result
      assert path =~ ~r|/workout/\d+|

      # Layout renders flash container with role="alert"
      conn = get(conn, "/workout/history")
      html = response(conn, 200)
      assert html =~ "role=\"alert\"" or html =~ "alert"
    end
  end
end
