defmodule Phoenixgym.Exercises.Exercise do
  use Ecto.Schema
  import Ecto.Changeset

  schema "exercises" do
    field :name, :string
    field :category, :string
    field :primary_muscle, :string
    field :secondary_muscles, {:array, :string}, default: []
    field :equipment, :string
    field :instructions, :string
    field :is_custom, :boolean, default: false

    has_many :routine_exercises, Phoenixgym.Routines.RoutineExercise
    has_many :workout_exercises, Phoenixgym.Workouts.WorkoutExercise
    has_many :personal_records, Phoenixgym.Records.PersonalRecord

    timestamps(type: :utc_datetime)
  end

  @categories ~w(strength cardio olympic plyometric flexibility other)
  @muscles ~w(chest back shoulders biceps triceps legs glutes core calves forearms full_body cardio)
  @equipment ~w(barbell dumbbell cable machine bodyweight kettlebell resistance_band other)

  def changeset(exercise, attrs) do
    exercise
    |> cast(attrs, [
      :name,
      :category,
      :primary_muscle,
      :secondary_muscles,
      :equipment,
      :instructions,
      :is_custom
    ])
    |> validate_required([:name])
    |> validate_inclusion(:category, @categories,
      message: "must be one of: #{Enum.join(@categories, ", ")}"
    )
    |> validate_inclusion(:primary_muscle, @muscles, message: "must be a valid muscle group")
    |> validate_inclusion(:equipment, @equipment, message: "must be a valid equipment type")
    |> unique_constraint(:name)
  end

  def categories, do: @categories
  def muscles, do: @muscles
  def equipment_types, do: @equipment
end
