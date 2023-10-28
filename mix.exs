defmodule ServerTiming.MixProject do
  use Mix.Project

  @version "0.1.0-dev"
  @description "Time plugs and expose results through the Server Timing Header."

  def project do
    [
      app: :server_timing,
      name: "ServerTiming",
      version: @version,
      description: @description,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:plug, "~> 1.15"},
    ]
  end
end
