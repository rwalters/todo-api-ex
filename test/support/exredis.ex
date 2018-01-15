defmodule Exredis do
  use GenServer

  # Client

  def init(args) do
    {:ok, args}
  end

  def start_link() do
    GenServer.start_link(__MODULE__, %{}, [name: Exredis])

    {:ok, :pid}
  end

  defmodule Api do
    def setex(_pid, key, _timeout, value) do
      GenServer.cast(Exredis, {:push, {key, value}})
    end

    def get(_pid, key) do
      GenServer.call(Exredis, {:pop, key})
    end
  end

  # Server (callbacks)

  def handle_call({:pop, key}, _from, state) do
    {:reply, state[key], state}
  end

  def handle_call(request, from, state) do
    # Call the default implementation from GenServer
    super(request, from, state)
  end

  def handle_cast({:push, {key, value}}, state) do
    {:noreply, Map.merge(state, %{key => value})}
  end

  def handle_cast(request, state) do
    super(request, state)
  end
end
