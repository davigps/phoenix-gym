defmodule PhoenixgymWeb.PageController do
  use PhoenixgymWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
