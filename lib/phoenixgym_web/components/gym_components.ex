defmodule PhoenixgymWeb.GymComponents do
  use PhoenixgymWeb, :html

  alias Phoenixgym.Units

  @moduledoc """
  App-specific DaisyUI components for PhoenixGym.
  """

  # ── Bottom Navigation Bar ───────────────────────────────────────────────

  attr :active, :atom,
    required: true,
    doc: "The currently active tab: :dashboard | :exercises | :workout | :history | :profile"

  def bottom_nav(assigns) do
    tabs = [
      %{id: :dashboard, href: "/", icon: "hero-home-solid", label: "Home"},
      %{
        id: :routines,
        href: "/routines",
        icon: "hero-clipboard-document-list-solid",
        label: "Routines"
      },
      %{id: :workout, href: "/workout/active", icon: "hero-play-solid", label: "Workout"},
      %{id: :history, href: "/workout/history", icon: "hero-clock-solid", label: "History"},
      %{id: :profile, href: "/profile", icon: "hero-user-circle-solid", label: "Profile"}
    ]

    assigns = assign(assigns, :tabs, tabs)

    ~H"""
    <nav class="fixed bottom-0 left-0 right-0 z-50 bg-base-100 border-t border-base-300 safe-area-bottom">
      <div class="max-w-lg mx-auto flex items-end justify-around px-2 pt-1 pb-2">
        <a
          :for={tab <- @tabs}
          href={tab.href}
          aria-label={tab.label}
          class={[
            "flex flex-col items-center gap-0.5 min-w-0 flex-1 transition-colors",
            if(tab.id == :workout, do: "-mt-4", else: "pt-1"),
            if(@active == tab.id && tab.id != :workout,
              do: "text-primary",
              else: "text-base-content/50 hover:text-base-content/80"
            )
          ]}
        >
          <%= if tab.id == :workout do %>
            <span class={[
              "flex items-center justify-center h-12 w-12 rounded-full shadow-lg transition-transform hover:scale-105",
              if(@active == :workout, do: "bg-primary ring-2 ring-primary/30", else: "bg-primary")
            ]}>
              <.icon name={tab.icon} class="h-6 w-6 text-primary-content" />
            </span>
            <span class={[
              "text-[10px] font-medium leading-tight",
              if(@active == :workout, do: "text-primary", else: "text-base-content/50")
            ]}>
              {tab.label}
            </span>
          <% else %>
            <.icon
              name={if(@active == tab.id, do: tab.icon, else: String.replace(tab.icon, "-solid", ""))}
              class="h-6 w-6"
            />
            <span class={[
              "text-[10px] font-medium leading-tight",
              if(@active == tab.id, do: "text-primary", else: "")
            ]}>
              {tab.label}
            </span>
          <% end %>
        </a>
      </div>
    </nav>
    """
  end

  # ── Muscle Group Badge ──────────────────────────────────────────────────

  attr :muscle, :string, required: true

  def muscle_badge(assigns) do
    ~H"""
    <span class={["badge badge-sm", muscle_color(@muscle)]}>
      {muscle_label(@muscle)}
    </span>
    """
  end

  defp muscle_color("chest"), do: "badge-error"
  defp muscle_color("back"), do: "badge-info"
  defp muscle_color("shoulders"), do: "badge-warning"
  defp muscle_color("biceps"), do: "badge-success"
  defp muscle_color("triceps"), do: "badge-success"
  defp muscle_color("legs"), do: "badge-primary"
  defp muscle_color("glutes"), do: "badge-primary"
  defp muscle_color("core"), do: "badge-secondary"
  defp muscle_color("calves"), do: "badge-accent"
  defp muscle_color("forearms"), do: "badge-neutral"
  defp muscle_color("full_body"), do: "badge-ghost"
  defp muscle_color("cardio"), do: "badge-ghost"
  defp muscle_color(_), do: "badge-ghost"

  defp muscle_label("full_body"), do: "Full Body"
  defp muscle_label(m), do: String.capitalize(m)

  # ── Exercise Row ────────────────────────────────────────────────────────

  attr :exercise, :map, required: true
  attr :on_select, :string, default: nil
  attr :rest, :global

  def exercise_row(assigns) do
    ~H"""
    <div
      class="flex items-center gap-3 p-3 hover:bg-base-200 cursor-pointer rounded-lg transition-colors"
      {@rest}
    >
      <div class="flex-1 min-w-0">
        <p class="font-medium truncate">{@exercise.name}</p>
        <div class="flex gap-1 mt-0.5">
          <.muscle_badge muscle={@exercise.primary_muscle} />
          <span class="badge badge-sm badge-ghost">{@exercise.equipment}</span>
        </div>
      </div>
      <.icon name="hero-chevron-right" class="h-4 w-4 text-base-content/40 shrink-0" />
    </div>
    """
  end

  # ── Stat Card ───────────────────────────────────────────────────────────

  attr :label, :string, required: true
  attr :value, :string, required: true
  attr :icon, :string, default: nil
  attr :unit, :string, default: nil

  def stat_card(assigns) do
    ~H"""
    <div class="stat bg-base-200 rounded-box">
      <div :if={@icon} class="stat-figure text-primary">
        <.icon name={@icon} class="h-6 w-6" />
      </div>
      <div class="stat-title text-xs">{@label}</div>
      <div class="stat-value text-2xl">{@value}</div>
      <div :if={@unit} class="stat-desc">{@unit}</div>
    </div>
    """
  end

  # ── Workout Card (History) ───────────────────────────────────────────────

  attr :workout, :map, required: true
  attr :unit, :string, default: "kg"

  def workout_card(assigns) do
    ~H"""
    <div class="card bg-base-200 shadow-sm">
      <div class="card-body p-4">
        <div class="flex justify-between items-start">
          <div>
            <h3 class="card-title text-base">{@workout.name || "Workout"}</h3>
            <p class="text-sm text-base-content/60">
              {format_datetime(@workout.started_at)}
            </p>
          </div>
          <.icon name="hero-chevron-right" class="h-5 w-5 text-base-content/40" />
        </div>
        <div class="flex gap-4 mt-2 text-sm">
          <span :if={@workout.duration_seconds} class="flex items-center gap-1">
            <.icon name="hero-clock" class="h-4 w-4" />
            {format_duration(@workout.duration_seconds)}
          </span>
          <span :if={@workout.total_volume} class="flex items-center gap-1">
            <.icon name="hero-bolt" class="h-4 w-4" />
            {Units.display_weight(@workout.total_volume, @unit)}
          </span>
          <span :if={@workout.total_sets} class="flex items-center gap-1">
            <.icon name="hero-squares-2x2" class="h-4 w-4" />
            {@workout.total_sets} sets
          </span>
        </div>
      </div>
    </div>
    """
  end

  # ── Routine Card ────────────────────────────────────────────────────────

  attr :routine, :map, required: true

  def routine_card(assigns) do
    ~H"""
    <div class="card bg-base-200 shadow-sm">
      <div class="card-body p-4">
        <div class="flex justify-between items-center">
          <div>
            <h3 class="card-title text-base">{@routine.name}</h3>
            <p class="text-sm text-base-content/60">
              {length(@routine.routine_exercises)} exercises
            </p>
          </div>
          <.icon name="hero-chevron-right" class="h-5 w-5 text-base-content/40" />
        </div>
      </div>
    </div>
    """
  end

  # ── PR Badge ────────────────────────────────────────────────────────────

  attr :record, :map, required: true
  attr :unit, :string, default: "kg"

  def pr_badge(assigns) do
    ~H"""
    <div class="flex items-center gap-2 p-2 bg-warning/10 rounded-lg">
      <.icon name="hero-trophy" class="h-4 w-4 text-warning shrink-0" />
      <div class="text-sm">
        <span class="font-medium">{@record.exercise && @record.exercise.name}</span>
        <span class="text-base-content/60 ml-1">{pr_label(@record.record_type)}</span>
        <span class="font-bold ml-1">{format_pr_value(@record, @unit)}</span>
      </div>
    </div>
    """
  end

  defp pr_label("max_weight"), do: "Max Weight"
  defp pr_label("max_reps"), do: "Max Reps"
  defp pr_label("estimated_1rm"), do: "Est. 1RM"
  defp pr_label("max_volume_set"), do: "Max Set Volume"
  defp pr_label("max_volume_session"), do: "Max Session Volume"
  defp pr_label(type), do: type

  defp format_pr_value(%{record_type: "max_reps", value: v}, _unit),
    do: "#{Decimal.to_integer(v)} reps"

  defp format_pr_value(%{value: v}, unit), do: Units.display_weight(v, unit)

  # ── Confirm Modal ───────────────────────────────────────────────────────

  attr :id, :string, required: true
  attr :title, :string, required: true
  attr :message, :string, required: true
  attr :confirm_event, :string, required: true
  attr :confirm_label, :string, default: "Confirm"
  attr :confirm_class, :string, default: "btn-error"

  def confirm_modal(assigns) do
    ~H"""
    <dialog id={@id} class="modal modal-bottom sm:modal-middle">
      <div class="modal-box">
        <h3 class="font-bold text-lg">{@title}</h3>
        <p class="py-4">{@message}</p>
        <div class="modal-action">
          <form method="dialog">
            <button class="btn btn-ghost">Cancel</button>
          </form>
          <button class={["btn", @confirm_class]} phx-click={@confirm_event}>
            {@confirm_label}
          </button>
        </div>
      </div>
      <form method="dialog" class="modal-backdrop">
        <button>close</button>
      </form>
    </dialog>
    """
  end

  # ── Rest Timer Bar ──────────────────────────────────────────────────────

  attr :seconds_remaining, :integer, required: true
  attr :total_seconds, :integer, required: true

  def rest_timer(assigns) do
    ~H"""
    <div class="bg-base-200 px-4 py-2">
      <div class="flex items-center justify-between mb-1">
        <span class="text-sm font-medium">Rest</span>
        <span class="font-mono font-bold">{format_rest_time(@seconds_remaining)}</span>
        <button class="btn btn-xs btn-ghost" phx-click="skip_rest">Skip</button>
      </div>
      <progress
        class="progress progress-primary w-full"
        value={@total_seconds - @seconds_remaining}
        max={@total_seconds}
      >
      </progress>
    </div>
    """
  end

  defp format_rest_time(seconds) do
    m = div(seconds, 60)
    s = rem(seconds, 60)
    :io_lib.format("~B:~2..0B", [m, s]) |> IO.iodata_to_binary()
  end

  # ── Previous Sets Display ───────────────────────────────────────────────

  attr :sets, :list, required: true

  def previous_sets(assigns) do
    ~H"""
    <div :if={@sets != []} class="text-xs text-base-content/50 px-1 mb-1">
      <span class="font-medium">Last: </span>
      <span>
        {Enum.map_join(@sets, "  ", fn s ->
          weight = if s.weight, do: "#{Decimal.round(s.weight, 1)}kg", else: "—"
          reps = if s.reps, do: "×#{s.reps}", else: ""
          "#{weight}#{reps}"
        end)}
      </span>
    </div>
    """
  end

  # ── Empty State ─────────────────────────────────────────────────────────

  attr :icon, :string, default: "hero-inbox"
  attr :title, :string, required: true
  attr :description, :string, default: nil
  slot :actions

  def empty_state(assigns) do
    ~H"""
    <div class="flex flex-col items-center justify-center py-16 px-4 text-center">
      <.icon name={@icon} class="h-12 w-12 text-base-content/30 mb-4" />
      <h3 class="font-semibold text-lg">{@title}</h3>
      <p :if={@description} class="text-base-content/60 text-sm mt-1">{@description}</p>
      <div :if={@actions != []} class="mt-4">
        {render_slot(@actions)}
      </div>
    </div>
    """
  end

  # ── Page Header ─────────────────────────────────────────────────────────

  attr :title, :string, required: true
  slot :left
  slot :right

  def page_header(assigns) do
    ~H"""
    <div class="navbar bg-base-100 border-b border-base-300 sticky top-0 z-40 min-h-14 px-2">
      <div class="navbar-start">
        {render_slot(@left)}
      </div>
      <div class="navbar-center">
        <span class="font-semibold text-lg">{@title}</span>
      </div>
      <div class="navbar-end">
        {render_slot(@right)}
      </div>
    </div>
    """
  end

  # ── Exercise Picker Modal ────────────────────────────────────────────────

  @doc """
  A searchable exercise picker modal. Fires a `select_exercise` phx-click event
  with `phx-value-id` set to the exercise id. The parent LiveView must handle
  the `select_exercise` event and toggle `show` back to false.

  ## Attributes

  * `show` - boolean, whether the modal is visible
  * `exercises` - list of Exercise structs to display
  * `search` - current search string (controlled by parent)
  * `on_cancel` - JS command or event name to close the picker
  """

  attr :show, :boolean, default: false
  attr :exercises, :list, required: true
  attr :search, :string, default: ""
  attr :on_cancel, :string, default: "close_exercise_picker"
  attr :select_event, :string, default: "select_exercise"

  def exercise_picker(assigns) do
    ~H"""
    <div
      :if={@show}
      class="fixed inset-0 z-50 flex flex-col bg-base-100"
      role="dialog"
      aria-modal="true"
      aria-label="Select Exercise"
    >
      <%!-- Picker header --%>
      <div class="navbar bg-base-100 border-b border-base-300 min-h-14 px-2">
        <div class="navbar-start">
          <button
            class="btn btn-ghost btn-sm"
            phx-click={@on_cancel}
            aria-label="Cancel"
          >
            <.icon name="hero-x-mark" class="h-5 w-5" />
          </button>
        </div>
        <div class="navbar-center">
          <span class="font-semibold">Select Exercise</span>
        </div>
      </div>

      <%!-- Search --%>
      <div class="p-3 border-b border-base-300">
        <form phx-change="picker_search" phx-submit="picker_search">
          <label class="input input-bordered flex items-center gap-2 w-full">
            <.icon name="hero-magnifying-glass" class="h-4 w-4 opacity-50" />
            <input
              type="text"
              name="search"
              value={@search}
              placeholder="Search exercises..."
              class="grow"
              phx-debounce="200"
              autofocus
            />
          </label>
        </form>
      </div>

      <%!-- Exercise list --%>
      <div class="flex-1 overflow-y-auto divide-y divide-base-200">
        <div :if={@exercises == []} class="p-8 text-center text-base-content/50">
          No exercises found
        </div>
        <button
          :for={exercise <- @exercises}
          class="flex items-center gap-3 p-3 w-full text-left hover:bg-base-200 transition-colors"
          phx-click={@select_event}
          phx-value-id={exercise.id}
        >
          <div class="flex-1 min-w-0">
            <p class="font-medium truncate">{exercise.name}</p>
            <div class="flex gap-1 mt-0.5">
              <span class="badge badge-sm badge-ghost">
                {String.capitalize(exercise.primary_muscle || "")}
              </span>
              <span class="badge badge-sm badge-outline">
                {exercise.equipment}
              </span>
            </div>
          </div>
          <.icon name="hero-plus" class="h-4 w-4 text-base-content/40 shrink-0" />
        </button>
      </div>
    </div>
    """
  end

  # ── Volume Bar Chart ────────────────────────────────────────────────────

  attr :data, :list,
    required: true,
    doc: "List of {week_label, volume} tuples; volume is a Decimal"

  def volume_chart(assigns) do
    max_vol =
      Enum.reduce(assigns.data, 0.0, fn {_label, vol}, acc ->
        f = Decimal.to_float(vol || Decimal.new(0))
        max(f, acc)
      end)

    max_height = if max_vol > 0, do: max_vol, else: 1.0

    assigns = assign(assigns, :max_height, max_height)

    ~H"""
    <div class="w-full" id="volume-chart">
      <div class="flex items-end justify-between gap-1 h-24">
        <div
          :for={{label, vol} <- @data}
          class="flex-1 flex flex-col items-center gap-0.5 min-w-0"
          title={"#{label}: #{format_volume(vol)} kg"}
        >
          <div
            class="w-full bg-primary rounded-t transition-all min-h-[4px]"
            style={"height: #{max(Decimal.to_float(vol || Decimal.new(0)) / @max_height * 96, 2)}%"}
          >
          </div>
          <span class="text-[10px] text-base-content/60 truncate w-full text-center">{label}</span>
        </div>
      </div>
    </div>
    """
  end

  # ── Helpers ─────────────────────────────────────────────────────────────

  defp format_datetime(nil), do: ""

  defp format_datetime(dt) do
    dt
    |> DateTime.shift_zone!("Etc/UTC")
    |> Calendar.strftime("%b %-d, %Y · %-I:%M %p")
  end

  defp format_duration(nil), do: ""

  defp format_duration(seconds) do
    h = div(seconds, 3600)
    m = div(rem(seconds, 3600), 60)

    cond do
      h > 0 -> "#{h}h #{m}m"
      true -> "#{m}m"
    end
  end

  defp format_volume(nil), do: "0"

  defp format_volume(vol) do
    vol
    |> Decimal.round(1)
    |> Decimal.to_string()
  end
end
