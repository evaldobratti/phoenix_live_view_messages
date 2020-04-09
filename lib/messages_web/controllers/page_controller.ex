defmodule MessagesWeb.PageController do
  use MessagesWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", status_count: 10)
  end
end
