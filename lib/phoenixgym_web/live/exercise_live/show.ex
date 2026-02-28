defmodule PhoenixgymWeb.ExerciseLive.Show do
  use PhoenixgymWeb, :live_view

  alias Phoenixgym.Exercises
  alias Phoenixgym.Records

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_tab={:exercises}>
      <div class="flex flex-col">
        <%!-- Header --%>
        <div class="navbar bg-base-100 border-b border-base-300 sticky top-0 z-40 min-h-14 px-2">
          <div class="navbar-start">
            <a href="/exercises" class="btn btn-ghost btn-sm gap-1">
              <.icon name="hero-arrow-left" class="h-4 w-4" /> Back
            </a>
          </div>
          <div class="navbar-center">
            <span class="font-semibold">{@exercise.name}</span>
          </div>
        </div>

        <div class="p-4 space-y-4">
          <%!-- Exercise Info --%>
          <div class="flex gap-2 flex-wrap">
            <span class="badge badge-ghost">{@exercise.category}</span>
            <span class="badge badge-ghost">{@exercise.primary_muscle}</span>
            <span class="badge badge-outline">{@exercise.equipment}</span>
            <span :if={@exercise.is_custom} class="badge badge-secondary">Custom</span>
          </div>

          <div :if={@exercise.instructions} class="prose prose-sm max-w-none">
            <p>{@exercise.instructions}</p>
          </div>

          <%!-- Personal Records --%>
          <div>
            <h2 class="font-semibold text-lg mb-2">Personal Records</h2>
            <div :if={@records == %{}} class="text-base-content/50 text-sm">
              No records yet. Start logging this exercise!
            </div>
            <div :if={@records != %{}} class="space-y-2">
              <div
                :for={{type, record} <- @records}
                class="flex justify-between items-center p-2 bg-base-200 rounded-lg"
              >
                <span class="text-sm">{pr_label(type)}</span>
                <span class="font-bold">{format_pr(record)}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    exercise = Exercises.get_exercise!(id)
    records = Records.get_best_records(exercise.id)

    socket =
      socket
      |> assign(:exercise, exercise)
      |> assign(:records, records)
      |> assign(:page_title, exercise.name)

    {:ok, socket}
  end

  defp pr_label("max_weight"), do: "Max Weight"
  defp pr_label("max_reps"), do: "Max Reps"
  defp pr_label("estimated_1rm"), do: "Estimated 1RM"
  defp pr_label("max_volume_set"), do: "Max Set Volume"
  defp pr_label("max_volume_session"), do: "Max Session Volume"
  defp pr_label(t), do: t

  defp format_pr(%{record_type: "max_reps", value: v}), do: "#{Decimal.to_integer(v)} reps"
  defp format_pr(%{value: v}), do: "#{Decimal.round(v, 1)} kg"
end
