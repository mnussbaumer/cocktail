defmodule Cocktail.Persister do
  @type entry :: binary | term
  
  @callback start() :: {:ok, state :: term} | {:error, reason :: term}
  @callback save(page :: %Cocktail.Page{}, state :: term) :: {:ok, new_page :: %Cocktail.Page{}} | {:error, reason :: term}
  @callback load(id :: term, type :: atom, state :: term) :: {:ok, page :: %Cocktail.Page{}} | {:error, reason :: term}
  @callback entries(type :: atom, state :: term) :: {:ok, entries :: list(entry)} | {:error, reason :: term}
  @callback publish(page :: %Cocktail.Page{}, state :: term) :: {:ok, new_page :: %Cocktail.Page{}} | {:error, reason :: term}
  @callback delete(page :: %Cocktail.Page{}, state :: term) :: {:ok, delete :: %Cocktail.Page{}} | {:error, reason :: term}
  @callback published(type :: atom, metadata :: term, state :: term) :: {:ok, list(entry)} | {:error, reason :: term}
  @callback show(id :: term, type :: atom, state :: term) :: {:ok, page :: %Cocktail.Page{}} | {:error, reason :: term}
  @callback terminate(reason :: term, state :: term) :: any()

  defmacro __using__([]) do
    quote do
      @behaviour unquote(__MODULE__)

      def start_link(module_and_after_start) do
        Cocktail.Persister.Server.start_link(module_and_after_start)
      end
    end
  end
end
