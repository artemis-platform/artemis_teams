defmodule ArtemisWeb.EventInstanceFormLive do
  use ArtemisWeb.LiveView

  # LiveView Callbacks

  @impl true
  def mount(session, socket) do
    assigns =
      socket
      |> assign(:action, session.action)
      |> assign(:csrf_token, session.csrf_token)
      |> assign(:date, session.date)
      |> assign(:event_answers, session.event_answers)
      |> assign(:event_questions, session.event_questions)
      |> assign(:event_template, session.event_template)
      |> assign(:projects, session.projects)

    {:ok, assigns}
  end

  @impl true
  def render(assigns) do
    Phoenix.View.render(ArtemisWeb.EventInstanceView, "form.html", assigns)
  end

  # GenServer Callbacks

  @impl true
  def handle_info(:hello, socket) do
    assigns = assign(socket, :hello, [])

    {:noreply, assigns}
  end
end
