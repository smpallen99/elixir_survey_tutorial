defmodule Survey.Mixfile do
  use Mix.Project

  def project do
    [app: :survey,
     version: "0.0.2",
     elixir: "~> 1.3",
     elixirc_paths: elixirc_paths(Mix.env()),
     compilers: [:phoenix] ++ Mix.compilers,
     build_embedded: Mix.env() == :prod,
     start_permanent: Mix.env() == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [mod: {Survey, []},
     applications: [:phoenix, :phoenix_html, :cowboy, :logger,
                    :phoenix_ecto, :mariaex,
                    :ex_ami, :erlagi, :speak_ex]]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [{:phoenix, "~> 1.2"},
     {:phoenix_html, "~> 2.6"},
     {:ecto, "~> 2.1"},
     {:phoenix_ecto, "~> 3.2"},
     {:mariaex, ">= 0.0.0"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:ex_admin, github: "smpallen99/ex_admin"}, 
     {:speak_ex, github: "smpallen99/speak_ex"},
     {:cowboy, "~> 1.0"}]
  end
end
