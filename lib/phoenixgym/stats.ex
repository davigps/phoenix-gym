defmodule Phoenixgym.Stats do
  @moduledoc """
  Dashboard and aggregate stats: weekly volume, streak, top muscle groups.
  """
  import Ecto.Query
  alias Phoenixgym.Repo
  alias Phoenixgym.Workouts.Workout
  alias Phoenixgym.Workouts.WorkoutExercise
  alias Phoenixgym.Exercises.Exercise

  @doc """
  Returns 8 data points: one per week for the last 8 weeks.
  Each element is {week_label, total_volume} where volume is a Decimal (zero for weeks with no workouts).
  Weeks are ordered oldest first (index 0 = 8 weeks ago).
  """
  def weekly_volume do
    now = DateTime.utc_now()
    today = DateTime.to_date(now)

    # Build list of week start dates (last 8 weeks, oldest first)
    week_starts =
      for offset <- 7..0//-1 do
        Date.add(today, -offset * 7) |> beginning_of_week()
      end

    # Fetch all completed workouts in that range
    oldest = date_to_utc_datetime(List.first(week_starts))

    workouts =
      from(w in Workout,
        where: w.status == "completed",
        where: not is_nil(w.finished_at),
        where: w.finished_at >= ^oldest,
        select: %{finished_at: w.finished_at, total_volume: w.total_volume}
      )
      |> Repo.all()

    # Assign each workout to a week and sum volume per week
    week_volumes =
      Enum.reduce(workouts, %{}, fn w, acc ->
        dt = w.finished_at
        date = DateTime.to_date(dt)
        week_start = beginning_of_week(date)
        key = Date.to_iso8601(week_start)
        vol = w.total_volume || Decimal.new(0)
        Map.update(acc, key, vol, &Decimal.add(&1, vol))
      end)

    Enum.map(week_starts, fn week_start ->
      key = Date.to_iso8601(week_start)
      label = Calendar.strftime(week_start, "%b %d")
      volume = Map.get(week_volumes, key, Decimal.new(0))
      {label, volume}
    end)
  end

  defp beginning_of_week(date) do
    weekday = Date.day_of_week(date)
    days_back = weekday - 1
    Date.add(date, -days_back)
  end

  defp date_to_utc_datetime(date) do
    NaiveDateTime.new!(date.year, date.month, date.day, 0, 0, 0)
    |> DateTime.from_naive!("Etc/UTC")
  end

  @doc """
  Returns the number of consecutive days (including today) with at least one completed workout.
  Counts backwards from today.
  """
  def streak_count do
    today = DateTime.utc_now() |> DateTime.to_date()

    workouts =
      from(w in Workout,
        where: w.status == "completed",
        where: not is_nil(w.finished_at),
        select: w.finished_at
      )
      |> Repo.all()

    date_set =
      workouts
      |> Enum.map(&DateTime.to_date/1)
      |> Enum.map(&Date.to_iso8601/1)
      |> MapSet.new()

    count_consecutive_days(date_set, today, 0)
  end

  defp count_consecutive_days(date_set, date, count) do
    key = Date.to_iso8601(date)

    if MapSet.member?(date_set, key) do
      count_consecutive_days(date_set, Date.add(date, -1), count + 1)
    else
      count
    end
  end

  @doc """
  Returns top N muscle groups (primary_muscle) by count of exercises performed in completed workouts.
  Returns list of {muscle_name, count}, ordered by count descending.
  Uses recent completed workouts (last 100) to compute.
  """
  def top_muscle_groups(limit \\ 5) do
    recent_workout_ids =
      from(w in Workout,
        where: w.status == "completed",
        order_by: [desc: w.finished_at],
        limit: 100,
        select: w.id
      )
      |> Repo.all()

    if recent_workout_ids == [] do
      []
    else
      from(we in WorkoutExercise,
        join: e in Exercise,
        on: e.id == we.exercise_id,
        where: we.workout_id in ^recent_workout_ids,
        group_by: e.primary_muscle,
        order_by: [desc: count(we.id)],
        limit: ^limit,
        select: {e.primary_muscle, count(we.id)}
      )
      |> Repo.all()
    end
  end

  @doc "Returns total volume (sum of total_volume) for completed workouts in the current week."
  def volume_this_week do
    today = DateTime.utc_now() |> DateTime.to_date()
    week_start = beginning_of_week(today)
    week_end = Date.add(week_start, 6)
    start_dt = date_to_utc_datetime(week_start)
    end_dt = date_to_utc_datetime(week_end) |> end_of_day()

    from(w in Workout,
      where: w.status == "completed",
      where: not is_nil(w.finished_at),
      where: w.finished_at >= ^start_dt and w.finished_at <= ^end_dt,
      select: coalesce(sum(w.total_volume), 0)
    )
    |> Repo.one()
    |> case do
      nil -> Decimal.new(0)
      val -> val
    end
  end

  @doc "Returns total sets for completed workouts in the current week."
  def sets_this_week do
    today = DateTime.utc_now() |> DateTime.to_date()
    week_start = beginning_of_week(today)
    week_end = Date.add(week_start, 6)
    start_dt = date_to_utc_datetime(week_start)
    end_dt = date_to_utc_datetime(week_end) |> end_of_day()

    from(w in Workout,
      where: w.status == "completed",
      where: not is_nil(w.finished_at),
      where: w.finished_at >= ^start_dt and w.finished_at <= ^end_dt,
      select: coalesce(sum(w.total_sets), 0)
    )
    |> Repo.one() || 0
  end

  @doc "Returns count of completed workouts in the current calendar week (Mon–Sun)."
  def workouts_this_week do
    today = DateTime.utc_now() |> DateTime.to_date()
    week_start = beginning_of_week(today)
    week_end = Date.add(week_start, 6)
    start_dt = date_to_utc_datetime(week_start)
    end_dt = date_to_utc_datetime(week_end) |> end_of_day()

    from(w in Workout,
      where: w.status == "completed",
      where: not is_nil(w.finished_at),
      where: w.finished_at >= ^start_dt and w.finished_at <= ^end_dt,
      select: count(w.id)
    )
    |> Repo.one()
  end

  @doc "Returns count of completed workouts in the current calendar month."
  def workouts_this_month do
    now = DateTime.utc_now()
    today = DateTime.to_date(now)
    month_start = Date.beginning_of_month(today)
    month_end = Date.end_of_month(today)
    start_dt = date_to_utc_datetime(month_start)
    end_dt = date_to_utc_datetime(month_end) |> end_of_day()

    from(w in Workout,
      where: w.status == "completed",
      where: not is_nil(w.finished_at),
      where: w.finished_at >= ^start_dt and w.finished_at <= ^end_dt,
      select: count(w.id)
    )
    |> Repo.one()
  end

  defp end_of_day(dt) do
    DateTime.add(dt, 86400 - 1, :second)
  end
end
