defmodule TokenCache do
  use GenServer
  use Timex

  # Client

  def init(args) do
    {:ok, args}
  end

  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: TokenCache)

    {:ok, :pid}
  end

  defmodule Api do
    def set(_pid, key, value) do
      GenServer.cast(TokenCache, {:push, {key, {value, nil}}})
    end

    def setex(_pid, key, timeout, value) do
      expires_at =
        Timex.now()
        |> Timex.add(Duration.from_seconds(timeout))

      GenServer.cast(TokenCache, {:push, {key, {value, expires_at}}})
    end

    def get(_pid, key) do
      GenServer.call(TokenCache, {:pop, key})
    end
  end

  # Server (callbacks)

  defp get_key_with_timeout(state, key) do
    with {value, expires_at} when not is_nil(expires_at) <- Map.get(state, key),
         1 <- Timex.compare(expires_at, Timex.now()) do
      {:found, value}
    else
      {value, nil} -> {:found, value}
      nil -> {:notfound}
      x when x in -1..0 -> {:expired}
    end
  end

  def handle_call({:pop, key}, _from, state) do
    with {:found, value} <- get_key_with_timeout(state, key) do
      {:reply, value, state}
    else
      {:notfound} -> {:reply, nil, state}
      {:expired} -> {:reply, nil, Map.delete(state, key)}
    end
  end

  def handle_call(request, from, state) do
    # Call the default implementation from GenServer
    super(request, from, state)
  end

  def handle_cast({:push, {key, {value, timeout}}}, state) do
    {:noreply, Map.merge(state, %{key => {value, timeout}})}
  end

  def handle_cast(request, state) do
    super(request, state)
  end
end
