defmodule TokenCacheTest do
  use ExUnit.Case

  test "save and get value" do
    {:ok, client} = TokenCache.start_link()
    TokenCache.Api.setex(client, "token", 1200, true)
    assert TokenCache.Api.get(client, "token") == true
  end

  test "save value with expired timeout" do
    {:ok, client} = TokenCache.start_link()
    TokenCache.Api.setex(client, "token", -10, true)
    assert TokenCache.Api.get(client, "token") == nil
  end

  test "save value with no timeout" do
    {:ok, client} = TokenCache.start_link()
    TokenCache.Api.set(client, "token", true)
    assert TokenCache.Api.get(client, "token") == true
  end

  test "fetch value with invalid key" do
    {:ok, client} = TokenCache.start_link()
    assert TokenCache.Api.get(client, "neverset") == nil
  end
end
