defmodule Army.Command do

  @callback run(stage :: String.t, host :: Map.t, env :: Map.t,
                options :: Map.t, running :: any()) :: {:ok, String.t} | {:error, String.t}

  defmacro __using__(_opts) do
    quote do
      @behaviour Army.Command
      alias Army.Command
    end
  end

  @spec check_type(Map.t) :: Module.t
  def check_type(opts) do
    name = opts
           |> Map.keys()
           |> List.delete("name")
           |> List.delete("path")
           |> List.first()
           |> String.capitalize()
    Module.concat(Army.Command, name)
  end

  @spec add_path(Map.t) :: String.t
  def add_path(%{"path" => path}), do: "cd #{path} && "
  def add_path(_opts), do: ""

  @spec add_envs(Map.t) :: String.t
  def add_envs(envs) do
    envs
    |> Enum.map(&add_env/1)
    |> Enum.join(" ")
  end

  defp add_env(%{"env" => env}) do
    env
    |> Enum.map(fn {k, v} -> "#{k}=#{v}" end)
    |> Enum.join(" ")
  end

  @spec get_cmd_prefix(Map.t, Map.t) :: String.t
  def get_cmd_prefix(env, opts) do
    add_path(opts) <> add_envs(env)
  end

  @spec run(String.t, Map.t, Map.t, Module.t, Map.t, any()) :: {:ok, String.t} | {:error, String.t}
  def run(stage, host, env, module, opts, running) do
    apply(module, :run, [stage, host, env, opts, running])
  end
end
