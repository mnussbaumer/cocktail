defmodule Cocktail.Persister.DETS do
  use Cocktail.Persister

  @dets_pages :cocktail_pages
  @ets_pages :cocktail_ets_pages
  @dets_components :cocktail_components
  @ets_components :cocktail_ets_components
  
  @enforce_keys [:pages_table, :pages_ets_table, :components_table, :components_ets_table]
  defstruct [:pages_table, :pages_ets_table, :components_table, :components_ets_table]
  
  def start do
    case :dets.open_file(@dets_pages, []) do
      {:ok, pages_table} ->
        case :dets.open_file(@dets_components, []) do
          {:ok, components_table} ->
            ref = :ets.new(@ets_pages, [:named_table, :public])
            :dets.to_ets(@dets_pages, @ets_pages)
            ref_comps = :ets.new(@ets_components, [:named_table, :public])
            :dets.to_ets(@dets_components, @ets_components)
            
            {:ok, %__MODULE__{
                pages_table: pages_table, pages_ets_table: ref,
                components_table: components_table, components_ets_table: ref_comps
             }
            }
          {:error, reason} ->
            {:error, reason}
        end
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp dets_name(:page), do: @dets_pages
  defp dets_name(:component), do: @dets_components
  defp ets_name(:page), do: @ets_pages
  defp ets_name(:component), do: @ets_components

  def save(%{id: id, type: type} = page, _) do
    case :dets.insert(dets_name(type), {id, page}) do
      :ok ->
        :ets.insert(ets_name(type), {id, page})
        {:ok, page}
      {:error, reason} -> {:error, reason}
    end
  end

  def load(id, type, _) do
    case :ets.lookup(ets_name(type), id) do
      [] ->
        case :dets.lookup(dets_name(type), id) do
          [] -> {:error, "#{type} with id #{inspect id} wasn't found"}
          [{_, page}] -> {:ok, page}
        end
      [{_, page}] -> {:ok, page}
    end
  end

  def entries(type, _) do
    case :ets.select(ets_name(type), [{{:"$1", :"$2"}, [], [[:"$1", {:map_get, :title, :"$2"}]]}]) do
      [] ->
        case :dets.select(dets_name(type), [{{:"$1", :"$2"}, [], [[:"$1", {:map_get, :title, :"$2"}]]}]) do
          {:error, error} -> {:error, error}
          results -> results
        end
      results -> results
    end
  end

  def publish(%{id: id, type: type} = page, state) do
    case save(page, state) do
      {:ok, %{slug: slug} = n_page} ->
        case :dets.insert(dets_name(type), {{:published, id}, slug, n_page}) do
          :ok ->
            :ets.insert(ets_name(type), {{:published, id}, slug, n_page})
            {:ok, n_page}
          {:error, reason} -> {:error, reason}
        end
      {:error, reason} -> {:error, reason}
    end
  end


  def delete(%{id: id, type: type} = page, _) do
    case :dets.delete(dets_name(type), id) do
      :ok ->
        case :dets.delete(dets_name(type), {:published, id}) do
          :ok ->
            :ets.delete(ets_name(type), id)
            :ets.delete(ets_name(type), {:published, id})
            {:ok, page}
          {:error, reason} -> {:error, reason}
        end
      {:error, reason} -> {:error, reason}
    end
  end

  def published(type, _metadata, _) do
    case :ets.select(ets_name(type), [{{:"$1", :_, :"$2"}, [{:==, :published, {:element, 1, :"$1"}}], [:"$2"]}]) do
      [] ->
        case :dets.select(dets_name(type), [{{:"$1", :_, :"$2"}, [{:==, :published, {:element, 1, :"$1"}}], [:"$2"]}]) do
          {:error, error} -> {:error, error}
          results -> results
        end
      results -> results
    end
  end

  def show(id, type, _) do
    case :ets.select(ets_name(type), [{{:"$1", :_, :"$2"}, [{:==, :published, {:element, 1, :"$1"}}, {:==, id, {:element, 2, :"$1"}}], [:"$2"]}]) do
      [] ->
        case :dets.select(dets_name(type), [{{:"$1", :_, :"$2"}, [{:==, :published, {:element, 1, :"$1"}}, {:==, id, {:element, 2, :"$1"}}], [:"$2"]}]) do
          {:error, error} -> {:error, error}
          [] -> {:error, :not_found}
          page -> page
        end
      page -> page
    end
  end

  def terminate(_reason, _) do
    :dets.close(@dets_pages)
    :dets.close(@dets_components)
  end
end
