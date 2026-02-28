defmodule PhoenixgymWeb.RestoreLocale do
  @moduledoc """
  Sets Gettext locale in the LiveView process so form errors and all gettext calls use Portuguese.
  """
  def on_mount(:default, _params, _session, socket) do
    Gettext.put_locale(PhoenixgymWeb.Gettext, "pt")
    {:cont, socket}
  end
end
