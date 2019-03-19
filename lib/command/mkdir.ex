defmodule Army.Command.Mkdir do
  use Army.Command

  @impl true
  @spec run(stage :: String.t, host :: Map.t, env :: Map.t,
            options :: Map.t, running :: any()) :: {:ok, String.t} | {:error, String.t}
  def run(_stage, _host, _env, %{"mkdir" => path}, running) do
    running.("mkdir -p #{path}")
  end
end
