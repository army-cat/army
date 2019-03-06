defmodule Army do
  @moduledoc """
  Documentation for Army.
  """

  alias :trooper, as: Trooper
  alias :trooper_ssh, as: TrooperSsh

  @default_command_file "command.yaml"

  @doc false
  def main([]), do: army(@default_command_file)
  def main([file]), do: army(file)
  def main(_), do: usage()

  def army(filename) do
    [%{"hosts" => hosts,
       "commands" => commands}] = YamlElixir.read_all_from_file!(filename)
    for host <- hosts do
      cfg = parse_config(host)
      IO.puts "[host] connecting to #{inspect cfg}"
      {:ok, trooper} = TrooperSsh.start(cfg)
      for command <- commands do
        IO.puts "[command] #{inspect command}"
      end
      TrooperSsh.stop(trooper)
    end
  end

  defp parse_config(cfg) do
    ## FIXME: this should validate the SSH configuration to connect
    {file_id_rsa, cfg} = Map.pop(cfg, "file_id_rsa")
    id_rsa = File.read!(file_id_rsa)

    cfg
    |> Map.put("id_rsa", id_rsa)
    |> Stream.map(fn({k, v}) -> {String.to_atom(k), v} end)
    |> Enum.map(fn {:id_rsa, data} -> {:id_rsa, data}
                   other -> other
                end)
  end

  defp usage do
    IO.puts """
    Syntax: army [#{@default_command_file}]
    """
  end
end
