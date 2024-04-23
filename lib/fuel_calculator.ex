defmodule FuelCalculator do
  use GenServer

  def fuel_for_route(initial_mass, flight_route) do
    GenServer.call(__MODULE__, {:fuel_for_route, initial_mass, flight_route})
  end

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:fuel_for_route, initial_mass, flight_route}, _from, state) do
    result =
      with {:ok, route} <- read_destinations_gravity(flight_route) do
        route
        |> calc_fuel_for_route(initial_mass)
        |> then(&{:ok, &1})
      end

    {:reply, result, state}
  end

  defp calc_fuel_for_route(route, mass) do
    Enum.reduce(route, 0, fn {action, gravity}, acc ->
      fuel_formula =
        case action do
          :launch -> &fuel_for_launch(&1, gravity)
          :land -> &fuel_for_landing(&1, gravity)
        end

      acc + total_fuel(acc + mass, fuel_formula)
    end)
  end

  defp total_fuel(mass, fuel_formula) do
    mass
    |> then(fuel_formula)
    |> Stream.iterate(fuel_formula)
    |> Stream.take_while(&(&1 > 0))
    |> Enum.sum()
  end

  defp fuel_for_launch(mass, gravity) do
    floor(mass * gravity * 0.042 - 33)
  end

  defp fuel_for_landing(mass, gravity) do
    floor(mass * gravity * 0.033 - 42)
  end

  defp read_destinations_gravity(destinations) do
    Enum.reduce_while(destinations, {:ok, []}, fn {action, dest}, {:ok, acc} ->
      case destination_to_gravity(dest) do
        {:ok, gravity} -> {:cont, {:ok, [{action, gravity} | acc]}}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
  end

  defp destination_to_gravity("earth"), do: {:ok, 9.807}
  defp destination_to_gravity("moon"), do: {:ok, 1.62}
  defp destination_to_gravity("mars"), do: {:ok, 3.711}
  defp destination_to_gravity(dest), do: {:error, "Unknown destination: #{inspect(dest)}"}
end
