defmodule FuelCalculator.Supervisor do
  use Supervisor

  def start_link(state \\ []) do
    Supervisor.start_link(__MODULE__, state)
  end

  def init(_state) do
    fuel_calculator = %{
      id: FuelCalculator,
      start: {FuelCalculator, :start_link, []}
    }

    Supervisor.init([fuel_calculator], strategy: :one_for_one)
  end
end
