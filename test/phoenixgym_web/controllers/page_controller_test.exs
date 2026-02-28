defmodule PhoenixgymWeb.PageControllerTest do
  use PhoenixgymWeb.ConnCase

  test "GET / redirects to log-in when not authenticated", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert redirected_to(conn) == ~p"/users/log-in"
  end

  test "GET / returns dashboard when authenticated", %{conn: conn} do
    %{conn: conn} = register_and_log_in_user(%{conn: conn})
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "PhoenixGym"
  end
end
