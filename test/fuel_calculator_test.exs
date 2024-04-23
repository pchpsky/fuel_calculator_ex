defmodule FuelCalculatorTest do
  use ExUnit.Case

  describe "fuel_for_route/2" do
    test "calculates the total fuel required for landing Apollo 11 on Earth" do
      mass = 28_801
      flight_route = [land: "earth"]

      assert {:ok, 13_447} = FuelCalculator.fuel_for_route(mass, flight_route)
    end

    test "calculates the total fuel required for Apollo 11 mission" do
      mass = 28_801

      flight_route = [
        launch: "earth",
        land: "moon",
        launch: "moon",
        land: "earth"
      ]

      assert {:ok, 51_898} = FuelCalculator.fuel_for_route(mass, flight_route)
    end

    test "calculates the total fuel required for mission on Mars" do
      mass = 14_606

      flight_route = [
        launch: "earth",
        land: "mars",
        launch: "mars",
        land: "earth"
      ]

      assert {:ok, 33_388} = FuelCalculator.fuel_for_route(mass, flight_route)
    end

    test "calculates the total fuel required for passanger ship" do
      mass = 75_432

      flight_route = [
        launch: "earth",
        land: "moon",
        launch: "moon",
        land: "mars",
        launch: "mars",
        land: "earth"
      ]

      assert {:ok, 212_161} = FuelCalculator.fuel_for_route(mass, flight_route)
    end

    test "when destination is unknown returns an error" do
      mass = 75_432

      flight_route = [
        launch: "earth",
        land: "mars",
        launch: "mars",
        land: "jupiter"
      ]

      assert {:error, ~s(Unknown destination: "jupiter")} =
               FuelCalculator.fuel_for_route(mass, flight_route)
    end
  end
end
