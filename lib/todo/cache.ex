defmodule Todo.Cache do
  alias Todo.Cache

  use GenServer
  use Timex

  def start_link(_opts \\ []) do
    GenServer.start_link(
      __MODULE__,
      [
        {:ets_table_name, :cache_table},
        {:log_limit, 1_000_000}
      ],
      name: Cache
    )
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def setex(key, timeout, value) do
    expires_at =
      Timex.now()
      |> Timex.add(Duration.from_seconds(timeout))

    GenServer.call(__MODULE__, {:set, key, {value, expires_at}})
  end

  def set(key, value) do
    GenServer.call(__MODULE__, {:set, key, {value, nil}})
  end

  # GenServer callbacks

  defp get_key_with_timeout(%{ets_table_name: ets_table_name} = _state, key) do
    with [{_key, {value, expires_at}}] when not is_nil(expires_at) <-
           :ets.lookup(ets_table_name, key),
         1 <- Timex.compare(expires_at, Timex.now()) do
      {:found, value}
    else
      [{_key, {value, nil}}] ->
        {:found, value}

      x when x <= 0 ->
        :ets.delete(ets_table_name, key)
        {:expired}

      _ ->
        {:not_found}
    end
  end

  def handle_call({:get, key}, _from, state) do
    case get_key_with_timeout(state, key) do
      {:found, result} -> {:reply, result, state}
      {:expired} -> {:reply, nil, state}
      {:not_found} -> {:reply, nil, state}
    end
  end

  def handle_call({:set, key, value}, _from, state) do
    %{ets_table_name: ets_table_name} = state
    true = :ets.insert(ets_table_name, {key, value})
    {:reply, value, state}
  end

  def init(args) do
    [{:ets_table_name, ets_table_name}, {:log_limit, log_limit}] = args

    :ets.new(ets_table_name, [:named_table, :set, :private])

    {:ok, %{log_limit: log_limit, ets_table_name: ets_table_name}}
  end
end
