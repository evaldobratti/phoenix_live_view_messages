defmodule MessagesWeb.StatusLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <%= assigns.status %>
    """
  end

  def mount(_params, %{"id" => id}, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Messages.PubSub, "status:#{id}")
    end

    {:ok, assign(socket, status: "waiting")}
  end

  def handle_info("sent", socket) do
    IO.inspect("ra")
    {:noreply, assign(socket, status: "sent")}
  end
end
