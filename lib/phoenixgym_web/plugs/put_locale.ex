defmodule PhoenixgymWeb.Plugs.PutLocale do
  @moduledoc """
  Sets the Gettext locale to Portuguese (Brazil) for every request.
  """
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    Gettext.put_locale(PhoenixgymWeb.Gettext, "pt")

    assign(conn, :locale, "pt")
  end
end
