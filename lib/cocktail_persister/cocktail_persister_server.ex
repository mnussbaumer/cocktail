defmodule Cocktail.Persister.Server do
  use GenServer
  require Logger

  @enforce_keys [:mod]
  defstruct [:mod, :state]

  def start_link({module, after_start}) do
    Logger.info("Starting Cocktail.Persister")
    GenServer.start_link(__MODULE__, {module, after_start}, name: __MODULE__)
  end

  def init({module, after_start}) do
    case module.start() do
      {:ok, inner_state} -> {:ok, %__MODULE__{mod: module, state: inner_state}, {:continue, {:after_start, after_start}}}
      {:error, _} = error -> error
      other ->
        Logger.error("Cocktail.Persister wrong callback for start/0, it should return {:ok, state} or {:error, reason}, got #{inspect other}")
        {:error, other}
    end
  end

  def terminate(reason, %{mod: mod, state: inner_state}) do
    mod.terminate(reason, inner_state)
  end

  def handle_continue({:after_start, {m, f, a}}, %{mod: mod, state: inner_state} = state) do
    args = case a do
             a when is_nil(a) or a == [] or a == %{} ->
               [mod, inner_state]
             _ ->
               [mod, inner_state, a]
           end

    apply(m, f, args)
    {:noreply, state}
  end
  def handle_continue({:after_start, _}, state), do: {:noreply, state}

  def handle_call({:save, page}, _from, %{mod: mod, state: inner_state} = state) do
    case mod.save(Cocktail.Page.timestamp_save(page), inner_state) do
      {:ok, new_page} -> {:reply, {:ok, new_page}, state}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  def handle_call({:load, type, id}, _from, %{mod: mod, state: inner_state} = state) do
    case mod.load(id, type, inner_state) do
      {:ok, page} -> {:reply, {:ok, page}, state}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  def handle_call({:publish, page}, _from, %{mod: mod, state: inner_state} = state) do
    case mod.publish(Cocktail.Page.timestamp_publish(page), inner_state) do
      {:ok, new_page} -> {:reply, {:ok, new_page}, state}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  def handle_call({:delete, page}, _from, %{mod: mod, state: inner_state} = state) do
    case mod.delete(page, inner_state) do
      {:ok, old_page} -> {:reply, {:ok, old_page}, state}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  def handle_call(:load_components, _from, %{mod: mod, state: inner_state} = state) do
    case mod.entries(:component, inner_state) do
      {:error, error} -> {:reply, [], state}
      entries -> {:reply, entries, state}
    end
  end

  def handle_cast(cast_msg, state) do
    Logger.error("Cocktail.Persister received a cast when not expecting it:\n #{inspect cast_msg}\n")
    {:noreply, state}
  end

  def handle_info(msg, state) do
    Logger.error("Cocktail.Persister received a message when not expecting it:\n #{inspect msg}")
    {:noreply, state}
  end

  def load_components() do
    GenServer.call(__MODULE__, :load_components)
  end
end
