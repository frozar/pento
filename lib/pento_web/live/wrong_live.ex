defmodule PentoWeb.WrongLive do
  use PentoWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       score: 0,
       message: "Make a guess!",
       time: time(),
       winning_number: Enum.random(1..10),
       won: false
     )}
  end

  def handle_event("guess", %{"number" => guess}, socket) do
    user_wins? = String.to_integer(guess) == socket.assigns.winning_number

    message =
      "Your guess: #{guess}." <> if user_wins?, do: " You win!", else: " Wrong. Guess again. "

    score = if user_wins?, do: socket.assigns.score + 1, else: socket.assigns.score - 1

    {
      :noreply,
      assign(
        socket,
        message: message,
        score: score,
        time: time(),
        won: user_wins?
      )
    }
  end

  def handle_params(%{"restart" => "true"}, _uri, socket) do
    {:noreply,
     socket
     |> assign(:message, "Make a guess!")
     |> assign(:winning_number, Enum.random(1..10))
     |> assign(:won, false)
     |> assign(time: time())}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <h1>Your score: {@score}</h1>
    <h2>
      {@message}
    </h2>
    It's {@time}
    <h2>
      <%= for n <- 1..10 do %>
        <.link href="#" phx-click="guess" phx-value-number={n}>
          {n}
        </.link>
      <% end %>
      <pre>
        <%= @current_scope.user.email %>
        <%= @session_id %>
      </pre>
    </h2>

    <%= if @won do %>
      <.link patch={~p"/guess?restart=true"} class="button">
        Restart
      </.link>
    <% end %>
    """
  end

  def time() do
    DateTime.utc_now() |> to_string
  end
end
