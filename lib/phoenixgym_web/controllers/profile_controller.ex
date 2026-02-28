defmodule PhoenixgymWeb.ProfileController do
  use PhoenixgymWeb, :controller

  def set_unit(conn, %{"unit" => unit}) when unit in ["kg", "lbs"] do
    conn
    |> put_session("unit", unit)
    |> redirect(to: "/profile")
  end

  def set_unit(conn, _params) do
    redirect(conn, to: "/profile")
  end

  def update_preferences(conn, %{"display_name" => name}) do
    conn
    |> put_session("display_name", name)
    |> put_flash(:info, "Profile updated")
    |> redirect(to: "/profile")
  end

  def update_preferences(conn, _params) do
    redirect(conn, to: "/profile")
  end
end
