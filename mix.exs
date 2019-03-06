defmodule Army.MixProject do
  use Mix.Project

  def project do
    [
      app: :army,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: false,
      deps: deps(),
      escript: [main_module: Army]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:yaml_elixir, "~> 2.1"},
      {:trooper, "~> 0.3"},
    ]
  end
end
