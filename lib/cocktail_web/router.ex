defmodule CocktailWeb.Router do
  use CocktailWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/cocktail-editor", CocktailWeb do
    pipe_through :browser

    get "/", CocktailController, :index
    get "/:id", CocktailController, :edit
    get "/component/:id", CocktailController, :edit_component
    get "/component/preview/:id", CocktailController, :show_component
    get "/preview/:id", CocktailController, :show
    get "/html/:id", CocktailController, :as_html
    live "/live", Cocktail.Editor
  end

  scope "/", CocktailWeb do
    pipe_through :browser
    get "/", CocktailPublicController, :index
    get "/page/:id", CocktailPublicController, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", CocktailWeb do
  #   pipe_through :api
  # end
end
