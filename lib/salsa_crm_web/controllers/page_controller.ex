defmodule SalsaCrmWeb.PageController do
  use SalsaCrmWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
