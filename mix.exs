defmodule SalsaCrm.MixProject do
  use Mix.Project

  def project do
    [
      app: :salsa_crm,
      version: "1.0.1",
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      releases: [
        salsa_crm: [
          include_excecutables_for: [:unix],
          steps: [:assemble]
        ]
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {SalsaCrm.Application, []},
      extra_applications: [:logger, :runtime_tools, :crypto, :hackney]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # --------- Phoenix Deps --------
      {:phoenix, "~> 1.5"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      # ---------- Absinthe / Graphql ------------
      {:absinthe, "~> 1.5.5"},
      {:absinthe_plug, "~> 1.5"},
      {:absinthe_phoenix, "~> 2.0"},
      {:absinthe_relay, "~> 1.5.1"},
      {:neuron, "~> 5.0"},
      # ---------- HTML Utilities --------------
      {:poison, "~> 4.0.1"},
      {:httpoison, "~> 1.7.0"},
      {:plug_cowboy, "~> 2.4"},
      # ----------- Database Deps -------------
      {:scrivener_list, "~> 2.0.1"},
      {:ecto_sql, "~> 3.1"},
      {:ecto_enum, "~> 1.4"},
      {:postgrex, ">= 0.0.0"},
      # -------------- Others -----------
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:elixir_xml_to_map, "~> 2.0"},
      {:solana, "~> 0.2.0"},
      {:distillery, "~> 2.1"},
      {:numbers, "~> 5.2"},
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
