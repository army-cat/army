defmodule ArmyTest do
  use ExUnit.Case
  doctest Army

  test "greets the world" do
    assert Army.hello() == :world
  end
end
