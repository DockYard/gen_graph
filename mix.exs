defmodule GenGraph.MixProject do
  use Mix.Project

  @source_url "https://github.com/DockYard/gen_graph"
  @version "0.1.1"

  def project do
    [
      name: "GenGraph",
      app: :gen_graph,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env()),
      description: description(),
      deps: deps(),
      docs: docs()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp description do
    "GenGraph"
  end

  defp docs do
    [
      extras: extras(),
      main: "readme",
      source_url: @source_url,
      source_ref: @version
    ]
  end

  defp extras do
    ["README.md", "LICENSE.md"]
  end

  def package do
    %{
      maintainers: ["Brian Cardarella"],
      files: ~w(lib mix.exs README.md LICENSE.md),
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Built by DockYard, Expert Elixir & Phoenix Consultants" => "https://dockyard.com/phoenix-consulting"
      }
    }
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
      {:inflex, "~> 2.1"},
      {:gen_object, "~> 0.2.1"},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end
end
