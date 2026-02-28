defmodule Phoenixgym.Exercises do
  import Ecto.Query
  alias Phoenixgym.Repo
  alias Phoenixgym.Exercises.Exercise

  @doc "Returns all exercises, optionally filtered."
  def list_exercises(opts \\ []) do
    Exercise
    |> filter_by_search(opts[:search])
    |> filter_by_muscle(opts[:primary_muscle])
    |> filter_by_equipment(opts[:equipment])
    |> filter_by_category(opts[:category])
    |> order_by([e], asc: e.name)
    |> Repo.all()
  end

  defp filter_by_search(query, nil), do: query
  defp filter_by_search(query, ""), do: query

  defp filter_by_search(query, search) do
    term = "%#{search}%"
    where(query, [e], ilike(e.name, ^term))
  end

  defp filter_by_muscle(query, nil), do: query
  defp filter_by_muscle(query, ""), do: query
  defp filter_by_muscle(query, muscle), do: where(query, [e], e.primary_muscle == ^muscle)

  defp filter_by_equipment(query, nil), do: query
  defp filter_by_equipment(query, ""), do: query
  defp filter_by_equipment(query, equipment), do: where(query, [e], e.equipment == ^equipment)

  defp filter_by_category(query, nil), do: query
  defp filter_by_category(query, ""), do: query
  defp filter_by_category(query, category), do: where(query, [e], e.category == ^category)

  @doc "Gets a single exercise by id."
  def get_exercise!(id), do: Repo.get!(Exercise, id)

  @doc "Creates a custom exercise."
  def create_exercise(attrs \\ %{}) do
    %Exercise{}
    |> Exercise.changeset(Map.put(attrs, "is_custom", true))
    |> Repo.insert()
  end

  @doc "Updates an exercise."
  def update_exercise(%Exercise{} = exercise, attrs) do
    exercise
    |> Exercise.changeset(attrs)
    |> Repo.update()
  end

  @doc "Deletes a custom exercise."
  def delete_exercise(%Exercise{is_custom: true} = exercise) do
    Repo.delete(exercise)
  end

  @doc "Returns a changeset for the exercise."
  def change_exercise(%Exercise{} = exercise, attrs \\ %{}) do
    Exercise.changeset(exercise, attrs)
  end
end
