defmodule TokenCacheTest do
  use ExUnit.Case

  test "save and get value" do
    {:ok, client} = TokenCache.start_link()
    TokenCache.Api.setex(client, "token", 1200, true)
    assert TokenCache.Api.get(client, "token") == true
  end
end
