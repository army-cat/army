defmodule Army.Log do

  @type maybe_string :: String.t | nil

  @spec debug(maybe_string, maybe_string, String.t) :: :ok
  def debug(stage \\ nil, host \\ nil, msg), do: IO.puts "#{IO.ANSI.green}[debug]#{log(stage, host, msg)}"

  @spec info(maybe_string, maybe_string, String.t) :: :ok
  def info(stage \\ nil, host \\ nil, msg), do: IO.puts "#{IO.ANSI.blue}[info]#{log(stage, host, msg)}"

  @spec warn(maybe_string, maybe_string, String.t) :: :ok
  def warn(stage \\ nil, host \\ nil, msg), do: IO.puts "#{IO.ANSI.yellow}[warn]#{log(stage, host, msg)}"

  @spec error(maybe_string, maybe_string, String.t) :: :ok
  def error(stage \\ nil, host \\ nil, msg), do: IO.puts "#{IO.ANSI.red}[error]#{log(stage, host, msg)}"

  @spec log(maybe_string, maybe_string, String.t) :: String.t
  def log(stage, nil, msg), do: log(stage, msg)
  def log(stage, host, msg), do: "#{IO.ANSI.cyan}[#{host}]#{log(stage, msg)}"

  @spec log(maybe_string, String.t) :: String.t
  def log(nil, msg), do: log(msg)
  def log(stage, msg), do: "#{IO.ANSI.magenta}[#{stage}] #{log(msg)}"

  @spec log(String.t) :: String.t
  def log(msg), do: "#{IO.ANSI.reset}#{msg}"

end
