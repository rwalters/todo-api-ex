defmodule CacheTest do
  use ExUnit.Case

  test "cache" do
    Cache.start_link()
    Cache.set("token", 100)
    assert Cache.get("token") == 100
  end

  test "cache timeout" do
    Cache.start_link()
    Cache.setex("token", 1200, "abcdef")
    assert Cache.get("token") == "abcdef"
  end

  test "cache timeout expired" do
    Cache.start_link()
    Cache.setex("token", -1200, "abcdef")
    assert Cache.get("token") == nil
  end

  test "cache get unknown key" do
    Cache.start_link()
    assert Cache.get("not set token") == nil
  end
end
