defmodule Army.Command.Git do
  use Army.Command

  @impl true
  @spec run(stage :: String.t, host :: Map.t, env :: Map.t,
            options :: Map.t, running :: any()) :: {:ok, String.t} | {:error, String.t}
  def run(_stage, _host, _env, %{"git" => %{"command" => cmd}}, running) do
    running.("git #{cmd}")
  end
end
