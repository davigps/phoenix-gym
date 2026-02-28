defmodule PhoenixgymWeb.RoutineLive.Index do
  use PhoenixgymWeb, :live_view

  alias Phoenixgym.Routines
  alias Phoenixgym.Routines.Routine
  alias PhoenixgymWeb.CoreComponents

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_tab={:routines} current_scope={@current_scope}>
      <div class="flex flex-col">
        <%!-- Header --%>
        <div class="navbar bg-base-100 border-b border-base-300 sticky top-0 z-40 min-h-14 px-2">
          <div class="flex-1">
            <span class="font-semibold text-lg">{gettext("Routines")}</span>
          </div>
          <div class="flex-none">
            <a href="/routines/new" class="btn btn-ghost btn-sm gap-1">
              <.icon name="hero-plus" class="h-4 w-4" /> {gettext("New")}
            </a>
          </div>
        </div>

        <div :if={@live_action == :new} class="p-4 border-b border-base-300 bg-base-200">
          <h2 class="font-semibold mb-3">{gettext("New Routine")}</h2>
          <.form for={@form} phx-submit="create" phx-change="validate" class="space-y-3">
            <input
              type="text"
              name="routine[name]"
              value={@form[:name].value}
              class="input input-bordered w-full"
              placeholder={gettext("Routine name (e.g. Push Day A)")}
              autofocus
            />
            <p :for={err <- @form[:name].errors} class="text-error text-sm mt-1">
              {CoreComponents.translate_error(err)}
            </p>
            <textarea
              name="routine[notes]"
              class="textarea textarea-bordered w-full"
              placeholder={gettext("Notes (optional)")}
              rows="2"
            >{@form[:notes].value}</textarea>
            <div class="flex gap-2">
              <button type="submit" class="btn btn-primary flex-1">{gettext("Create")}</button>
              <a href="/routines" class="btn btn-ghost flex-1">{gettext("Cancel")}</a>
            </div>
          </.form>
        </div>

        <div class="p-4 space-y-3">
          <div :if={@routines == []}>
            <div class="flex flex-col items-center justify-center py-16 text-center">
              <.icon name="hero-clipboard-document-list" class="h-12 w-12 text-base-content/30 mb-4" />
              <h3 class="font-semibold text-lg">{gettext("No routines yet")}</h3>
              <p class="text-base-content/60 text-sm mt-1">
                {gettext("Create your first workout routine")}
              </p>
              <a href="/routines/new" class="btn btn-primary mt-4">
                <.icon name="hero-plus" class="h-4 w-4" /> {gettext("New Routine")}
              </a>
            </div>
          </div>

          <a
            :for={routine <- @routines}
            href={"/routines/#{routine.id}"}
            class="card bg-base-200 shadow-sm block"
          >
            <div class="card-body p-4">
              <div class="flex justify-between items-center">
                <div>
                  <h3 class="font-semibold">{routine.name}</h3>
                  <p class="text-sm text-base-content/60">
                    {gettext("%{count} exercises", count: length(routine.routine_exercises))}
                  </p>
                </div>
                <.icon name="hero-chevron-right" class="h-5 w-5 text-base-content/40" />
              </div>
            </div>
          </a>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    routines = Routines.list_routines()

    socket =
      socket
      |> assign(:routines, routines)
      |> assign(:form, to_form(Routines.change_routine(%Routine{})))
      |> assign(:page_title, gettext("Routines"))

    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"routine" => params}, socket) do
    form =
      %Routine{}
      |> Routines.change_routine(params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, form: form)}
  end

  @impl true
  def handle_event("create", %{"routine" => params}, socket) do
    case Routines.create_routine(params) do
      {:ok, routine} ->
        {:noreply, push_navigate(socket, to: "/routines/#{routine.id}/edit")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(Map.put(changeset, :action, :insert)))}
    end
  end
end
