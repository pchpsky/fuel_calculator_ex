defmodule FuelCalculator.Application do
  use Application

  def start(_type, _args) do
    FuelCalculator.Supervisor.start_link()
  end
end
