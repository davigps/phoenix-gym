defmodule PhoenixgymWeb.ExerciseLive.New do
  use PhoenixgymWeb, :live_view

  alias Phoenixgym.Exercises
  alias Phoenixgym.Exercises.Exercise

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_tab={:exercises}>
      <div class="flex flex-col">
        <%!-- Header --%>
        <div class="navbar bg-base-100 border-b border-base-300 sticky top-0 z-40 min-h-14 px-2">
          <div class="navbar-start">
            <a href="/exercises" class="btn btn-ghost btn-sm gap-1">
              <.icon name="hero-x-mark" class="h-4 w-4" />
            </a>
          </div>
          <div class="navbar-center">
            <span class="font-semibold">New Exercise</span>
          </div>
        </div>

        <div class="p-4">
          <.form for={@form} phx-submit="save" phx-change="validate" class="space-y-4">
            <div class="form-control">
              <label class="label"><span class="label-text">Name *</span></label>
              <input
                type="text"
                name="exercise[name]"
                value={@form[:name].value}
                class={["input input-bordered w-full", @form[:name].errors != [] && "input-error"]}
                placeholder="e.g. Romanian Deadlift"
              />
              <label :if={@form[:name].errors != []} class="label">
                <span class="label-text-alt text-error">
                  {Enum.map_join(@form[:name].errors, ", ", fn {msg, _} -> msg end)}
                </span>
              </label>
            </div>

            <div class="form-control">
              <label class="label"><span class="label-text">Category</span></label>
              <select name="exercise[category]" class="select select-bordered w-full">
                <option value="">Select category...</option>
                <option :for={cat <- Exercise.categories()} value={cat} selected={@form[:category].value == cat}>
                  {String.capitalize(cat)}
                </option>
              </select>
            </div>

            <div class="form-control">
              <label class="label"><span class="label-text">Primary Muscle</span></label>
              <select name="exercise[primary_muscle]" class="select select-bordered w-full">
                <option value="">Select muscle...</option>
                <option :for={m <- Exercise.muscles()} value={m} selected={@form[:primary_muscle].value == m}>
                  {String.capitalize(m)}
                </option>
              </select>
            </div>

            <div class="form-control">
              <label class="label"><span class="label-text">Equipment</span></label>
              <select name="exercise[equipment]" class="select select-bordered w-full">
                <option value="">Select equipment...</option>
                <option :for={eq <- Exercise.equipment_types()} value={eq} selected={@form[:equipment].value == eq}>
                  {String.capitalize(eq)}
                </option>
              </select>
            </div>

            <div class="form-control">
              <label class="label"><span class="label-text">Instructions</span></label>
              <textarea
                name="exercise[instructions]"
                class="textarea textarea-bordered w-full h-24"
                placeholder="How to perform this exercise..."
              >{@form[:instructions].value}</textarea>
            </div>

            <button type="submit" class="btn btn-primary w-full">Save Exercise</button>
          </.form>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    form = to_form(Exercises.change_exercise(%Exercise{}))

    socket =
      socket
      |> assign(:form, form)
      |> assign(:page_title, "New Exercise")

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"exercise" => params}, socket) do
    form =
      %Exercise{}
      |> Exercises.change_exercise(params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, form: form)}
  end

  @impl true
  def handle_event("save", %{"exercise" => params}, socket) do
    case Exercises.create_exercise(params) do
      {:ok, exercise} ->
        {:noreply,
         socket
         |> put_flash(:info, "Exercise created!")
         |> push_navigate(to: "/exercises/#{exercise.id}")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
