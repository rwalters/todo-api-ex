defmodule ExredisTest do
  use ExUnit.Case

  test "save and get value" do
    {:ok, client} = Exredis.start_link()
    Exredis.Api.setex(client, "token", 1200, true)
    assert Exredis.Api.get(client, "token") == true
  end
end
