defmodule Phoenixgym.Units do
  @moduledoc """
  Weight unit conversion (kg ↔ lbs). All weights are stored in kg in the DB;
  conversion is applied at display/input based on user preference.

  Conversion factor: 1 kg = 2.20462 lbs
  """

  @kg_to_lbs_factor 2.20462

  @doc """
  Converts kilograms to pounds.
  """
  def kg_to_lbs(nil), do: nil
  def kg_to_lbs(kg) when is_number(kg), do: kg * @kg_to_lbs_factor
  def kg_to_lbs(%Decimal{} = kg), do: kg |> Decimal.to_float() |> kg_to_lbs()

  @doc """
  Converts pounds to kilograms.
  """
  def lbs_to_kg(nil), do: nil
  def lbs_to_kg(lbs) when is_number(lbs), do: lbs / @kg_to_lbs_factor
  def lbs_to_kg(%Decimal{} = lbs), do: lbs |> Decimal.to_float() |> lbs_to_kg()

  @doc """
  Returns weight for display in the given unit. Value is assumed to be in kg (DB storage).
  Returns "—" for nil.
  """
  def display_weight(nil, _unit), do: "—"

  def display_weight(%Decimal{} = kg, "kg") do
    rounded = Decimal.round(kg, 1) |> Decimal.to_string()
    "#{rounded} kg"
  end

  def display_weight(%Decimal{} = kg, "lbs") do
    lbs = kg |> Decimal.to_float() |> kg_to_lbs()
    "#{Float.round(lbs, 1)} lbs"
  end

  def display_weight(kg, "kg") when is_number(kg) do
    "#{Float.round(kg, 1)} kg"
  end

  def display_weight(kg, "lbs") when is_number(kg) do
    lbs = kg_to_lbs(kg)
    "#{Float.round(lbs, 1)} lbs"
  end

  @doc """
  Converts a display value (string or number) from the given unit to kg for storage.
  Used when user enters weight in lbs — we convert to kg before saving.
  """
  def parse_to_kg(value, "kg") when is_binary(value) do
    case Float.parse(value) do
      {n, _} -> n
      :error -> nil
    end
  end

  def parse_to_kg(value, "lbs") when is_binary(value) do
    case Float.parse(value) do
      {lbs, _} -> lbs_to_kg(lbs)
      :error -> nil
    end
  end

  def parse_to_kg(value, "kg") when is_number(value), do: value
  def parse_to_kg(value, "lbs") when is_number(value), do: lbs_to_kg(value)
  def parse_to_kg(_, _), do: nil

  @doc """
  Converts kg (Decimal or number) to display value in the given unit.
  Used to pre-fill weight inputs (e.g. in active workout).
  """
  def kg_for_display(nil, _unit), do: ""
  def kg_for_display(%Decimal{} = kg, "kg"), do: Decimal.to_string(kg)

  def kg_for_display(%Decimal{} = kg, "lbs") do
    kg |> Decimal.to_float() |> kg_to_lbs() |> Float.round(1) |> to_string()
  end

  def kg_for_display(kg, "kg") when is_number(kg), do: to_string(Float.round(kg, 1))

  def kg_for_display(kg, "lbs") when is_number(kg),
    do: kg_to_lbs(kg) |> Float.round(1) |> to_string()

  def kg_for_display(_, _), do: ""
end
