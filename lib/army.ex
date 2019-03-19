defmodule Army do
  @moduledoc """
  Documentation for Army.
  """

  alias Army.{Command, Log}

  # alias :trooper, as: Trooper
  alias :trooper_ssh, as: TrooperSsh

  @default_command_file "command.yaml"
  @default_stage "dev"
  @errorlevel_timeout 127

  @doc false
  def main([]), do: army(@default_command_file, @default_stage)
  def main([file, stage]), do: army(file, stage)
  def main([file]), do: army(file, @default_stage)
  def main(_), do: usage()

  defp check_commands(commands, stage) do
    if stage in Map.keys(commands) do
      true
    else
      Log.error "no valid stage: #{stage}"
      false
    end
  end

  defp run([], _commands, _stage), do: true
  defp run([%{"host" => host} = host_cfg|hosts], commands, stage) do
    cfg = parse_config(host_cfg)
    Log.info stage, host, "connecting"
    Log.debug stage, host, "config => #{inspect cfg}"
    {:ok, trooper} = TrooperSsh.start(cfg)
    Log.debug stage, host, "commands => #{inspect commands}"
    env = for %{"env" => _} = env <- commands, do: env
    for %{"name" => name} = opts <- commands do
      module = Command.check_type(opts)
      Log.info stage, host, "=> #{name} (#{module})"
      running = fn raw_command ->
        command = Command.get_cmd_prefix(env, opts) <> raw_command
        Log.debug stage, host, "command to run => #{command}"
        out = case TrooperSsh.exec(trooper, String.to_charlist(command)) do
          {:ok, 0, output} -> {:ok, output}
          {:ok, error, txt} -> {:error, error, txt}
          {:error, :timeout} -> {:error, @errorlevel_timeout, "timeout error"}
        end
        Log.debug stage, host, "result => #{inspect out}"
        out
      end
      case Command.run(stage, host_cfg, env, module, opts, running) do
        {:ok, _} -> :ok
        {:error, errorlevel, error} ->
          Log.error stage, host, error
          System.halt(errorlevel)
      end
    end
    TrooperSsh.stop(trooper)
    run(hosts, commands, stage)
  end

  @spec army(String.t, String.t) :: false | :ok
  def army(filename, stage) do
    [%{"hosts" => hosts,
       "commands" => commands}] = YamlElixir.read_all_from_file!(filename)
    with true <- check_commands(commands, stage),
         true <- run(hosts, commands[stage], stage) do
      :ok
    end
  end

  defp parse_config(cfg) do
    ## FIXME: this should validate the SSH configuration to connect
    {file_id_rsa, cfg} = Map.pop(cfg, "file_id_rsa")
    id_rsa = File.read!(file_id_rsa)

    cfg
    |> Map.put("id_rsa", id_rsa)
    |> Stream.map(fn({k, v}) -> {String.to_atom(k), v} end)
    |> Enum.map(fn({:id_rsa, data}) -> {:id_rsa, data}
                  ({:user, user}) when is_binary(user) -> {:user, String.to_charlist(user)}
                  ({:host, host}) when is_binary(host) -> {:host, String.to_charlist(host)}
                  (other) -> other
                end)
  end

  defp usage do
    IO.puts """
    Syntax: army [#{@default_command_file}] [#{@default_stage}]
    """
  end
end
