defmodule MessagesWeb.SubmitLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <button phx-click="submit">
      <%= if any_waiting?(assigns.statuses) do %>
        Send
      <% else %>
        All sent
      <% end %>
    </button>
    """
  end

  def mount(_params, %{"total_messages" => total_messages}, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Messages.PubSub, "status")
    end

    statuses = Enum.map(0..total_messages, &({&1, "waiting"}))

    {:ok, assign(socket, statuses: statuses, total_messages: total_messages)}
  end

  def handle_event("submit", _value, socket) do

    Task.start(fn -> send_messages(socket.assigns.total_messages) end)

    {:noreply, socket}
  end

  def handle_info({id, status}, socket) do
    {:noreply, assign(socket, statuses: List.replace_at(socket.assigns.statuses, id, status))}
  end

  defp send_messages(total_messages) do
    Enum.each(0..total_messages, fn id ->
      :timer.sleep(500)

      IO.inspect(id)

      Phoenix.PubSub.broadcast!(Messages.PubSub, "status:#{id}", "sent")
      Phoenix.PubSub.broadcast!(Messages.PubSub, "status", {id, "sent"})
    end)
  end

  defp any_waiting?(statuses) do
    Enum.any?(statuses, fn
      {_id, "waiting"} ->
        true

      _ ->
        false
    end)
  end
end
