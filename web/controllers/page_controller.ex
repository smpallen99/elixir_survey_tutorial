defmodule Survey.PageController do
  use Survey.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
