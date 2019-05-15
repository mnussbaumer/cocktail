defmodule CocktailWeb.CocktailController do
  use CocktailWeb, :controller
  import Phoenix.LiveView.Controller, only: [live_render: 3]

  def index(conn, _params) do
    pages = Cocktail.Persister.DETS.entries(:page, nil)
    components = Cocktail.Persister.DETS.entries(:component, nil)
    render(conn, "index.html", pages: pages, components: components)
  end

  def edit(conn, %{"id" => id}) do
    conn
    |> put_layout({CocktailWeb.LayoutView, "editor.html"})
    |> live_render(Cocktail.View.Editor, session: {:load, :page, id})
  end

  def edit(conn, _) do
    conn
    |> put_layout({CocktailWeb.LayoutView, "editor.html"})
    |> live_render(Cocktail.View.Editor, session: Cocktail.Page.create_default())
  end

  def edit_component(conn, %{"id" => id}) do
    conn
    |> put_layout({CocktailWeb.LayoutView, "editor.html"})
    |> live_render(Cocktail.View.Editor, session: {:load, :component, id})
  end

  def show(conn, %{"id" => id}) do
    case Cocktail.Persister.DETS.load(id, :page, nil) do
      {:ok, page} ->
        Enum.reduce(page, conn, fn({k, v}, acc) ->
          assign(acc, k , v)
        end)
        |> assign(:additional, %{})
        |> assign(:export_html, false)
        |> put_layout({CocktailWeb.LayoutView, "page.html"})
        |> put_view(CocktailWeb.CocktailPublicView)
        |> render("page.html")

      {:error, :not_found} -> :ok
      {:error, _} -> :ok      
    end
  end

  def show_component(conn, %{"id" => id}) do
    case Cocktail.Persister.DETS.load(id, :component, nil) do
      {:ok, page} ->
        Enum.reduce(page, conn, fn({k, v}, acc) ->
          assign(acc, k , v)
        end)
        |> assign(:additional, %{})
        |> put_layout({CocktailWeb.LayoutView, "page.html"})
        |> put_view(CocktailWeb.CocktailPublicView)
        |> render("page.html")

      {:error, :not_found} -> :ok
      {:error, _} -> :ok      
    end
  end

  def as_html(conn, %{"id" => id}) do
    case Cocktail.Persister.DETS.show(id, :page, nil) do
      [page] ->
        assigns =
          Enum.reduce(
            page,
            %{
              layout: {CocktailWeb.LayoutView, "page.html"},
              conn: conn,
              export_html: true
            },
            fn({k,v}, acc) ->
              Map.put(acc, k, v)
            end)
            |> Map.put(:additional, %{})
            |> Enum.into([])

        html = Phoenix.View.render_to_string(CocktailWeb.CocktailPublicView, "page.html", assigns)
        IO.inspect(html, label: "html")
        text(conn, html)
      [_|_] = pages ->
        render(conn, "index.html", pages: pages)
      _ ->
        conn
        |> put_view(CocktailWeb.ErrorView)
        |> render("404.html")
    end
  end

end
