defmodule CocktailWeb.CocktailPublicController do
  use CocktailWeb, :controller

  def index(conn, _) do
    pages = Cocktail.Persister.DETS.published(:page, nil, nil)
    render(conn, "index.html", pages: pages)
  end

  def show(conn, %{"id" => id}) do
    case Cocktail.Persister.DETS.show(id, :page, nil) do
      [page] ->
        Enum.reduce(page, conn, fn({k,v}, acc) ->
          assign(acc, k, v)
        end)
        |> assign(:additional, %{})
        |> put_layout({CocktailWeb.LayoutView, "page.html"})
        |> render("page.html")

      [_|_] = pages ->
        render(conn, "index.html", pages: pages)
      _ ->
        conn
        |> put_view(CocktailWeb.ErrorView)
        |> render("404.html")
    end
  end
end
