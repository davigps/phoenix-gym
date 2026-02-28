defmodule Phoenixgym.UnitsTest do
  use ExUnit.Case, async: true

  alias Phoenixgym.Units

  describe "kg_to_lbs/1" do
    test "converts kg to lbs using factor 2.20462" do
      assert_in_delta Units.kg_to_lbs(1), 2.20462, 0.0001
      assert_in_delta Units.kg_to_lbs(10), 22.0462, 0.001
      assert_in_delta Units.kg_to_lbs(100), 220.462, 0.01
    end

    test "zero returns zero" do
      assert Units.kg_to_lbs(0) == 0.0
    end

    test "handles decimal input" do
      assert_in_delta Units.kg_to_lbs(2.5), 5.51155, 0.0001
    end

    test "handles very large values" do
      big = 10_000.0
      assert_in_delta Units.kg_to_lbs(big), 22046.2, 1.0
    end
  end

  describe "lbs_to_kg/1" do
    test "converts lbs to kg" do
      assert_in_delta Units.lbs_to_kg(2.20462), 1.0, 0.0001
      assert_in_delta Units.lbs_to_kg(22.0462), 10.0, 0.001
      assert_in_delta Units.lbs_to_kg(220.462), 100.0, 0.01
    end

    test "zero returns zero" do
      assert Units.lbs_to_kg(0) == 0.0
    end

    test "handles decimal input" do
      assert_in_delta Units.lbs_to_kg(5.51155), 2.5, 0.0001
    end

    test "handles very large values" do
      big = 22_046.2
      assert_in_delta Units.lbs_to_kg(big), 10_000.0, 1.0
    end
  end

  describe "round-trip conversion" do
    test "kg -> lbs -> kg within float tolerance" do
      for kg <- [0, 1, 10, 50, 100, 150.5, 200] do
        lbs = Units.kg_to_lbs(kg)
        back = Units.lbs_to_kg(lbs)

        assert_in_delta back,
                        kg,
                        0.0001,
                        "round-trip failed for kg=#{kg}: got lbs=#{lbs}, back=#{back}"
      end
    end

    test "lbs -> kg -> lbs within float tolerance" do
      for lbs <- [0, 10, 100, 225, 315.5] do
        kg = Units.lbs_to_kg(lbs)
        back = Units.kg_to_lbs(kg)

        assert_in_delta back,
                        lbs,
                        0.001,
                        "round-trip failed for lbs=#{lbs}: got kg=#{kg}, back=#{back}"
      end
    end
  end

  describe "display_weight/2" do
    test "returns kg string when unit is kg" do
      assert Units.display_weight(Decimal.new("100"), "kg") == "100.0 kg"
      assert Units.display_weight(Decimal.new("0"), "kg") == "0.0 kg"
    end

    test "returns lbs string when unit is lbs" do
      result = Units.display_weight(Decimal.new("100"), "lbs")
      assert result =~ "lbs"
      # 100 * 2.20462
      assert result =~ "220.5"
    end

    test "handles nil as dash" do
      assert Units.display_weight(nil, "kg") == "—"
      assert Units.display_weight(nil, "lbs") == "—"
    end
  end
end
