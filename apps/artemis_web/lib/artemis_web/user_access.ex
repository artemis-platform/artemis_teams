defmodule ArtemisWeb.UserAccess do
  @moduledoc """
  A thin wrapper around `Artemis.UserAccess`.

  Adds the ability to pull the current user from connection context.
  """
  import ArtemisWeb.Guardian.Helpers, only: [current_user: 1]

  alias Phoenix.LiveView.Socket
  alias Plug.Conn

  # User Permissions

  def has?(%Socket{} = socket, permission), do: Artemis.UserAccess.has?(socket.assigns.user, permission)
  def has?(%Conn{} = conn, permission), do: Artemis.UserAccess.has?(current_user(conn), permission)
  def has?(user, permission), do: Artemis.UserAccess.has?(user, permission)

  def has_any?(%Socket{} = socket, permission), do: Artemis.UserAccess.has_any?(socket.assigns.user, permission)
  def has_any?(%Conn{} = conn, permission), do: Artemis.UserAccess.has_any?(current_user(conn), permission)
  def has_any?(user, permission), do: Artemis.UserAccess.has_any?(user, permission)

  def has_all?(%Socket{} = socket, permission), do: Artemis.UserAccess.has_all?(socket.assigns.user, permission)
  def has_all?(%Conn{} = conn, permission), do: Artemis.UserAccess.has_all?(current_user(conn), permission)
  def has_all?(user, permission), do: Artemis.UserAccess.has_all?(user, permission)

  # User Teams

  def in_team?(%Socket{} = socket, team), do: Artemis.UserAccess.in_team?(socket.assigns.user, team)
  def in_team?(%Conn{} = conn, team), do: Artemis.UserAccess.in_team?(current_user(conn), team)
  def in_team?(user, team), do: Artemis.UserAccess.in_team?(user, team)

  def team_admin?(%Socket{} = socket, team), do: Artemis.UserAccess.team_admin?(socket.assigns.user, team)
  def team_admin?(%Conn{} = conn, team), do: Artemis.UserAccess.team_admin?(current_user(conn), team)
  def team_admin?(user, team), do: Artemis.UserAccess.team_admin?(user, team)

  def team_editor?(%Socket{} = socket, team), do: Artemis.UserAccess.team_editor?(socket.assigns.user, team)
  def team_editor?(%Conn{} = conn, team), do: Artemis.UserAccess.team_editor?(current_user(conn), team)
  def team_editor?(user, team), do: Artemis.UserAccess.team_editor?(user, team)

  def team_member?(%Socket{} = socket, team), do: Artemis.UserAccess.team_member?(socket.assigns.user, team)
  def team_member?(%Conn{} = conn, team), do: Artemis.UserAccess.team_member?(current_user(conn), team)
  def team_member?(user, team), do: Artemis.UserAccess.team_member?(user, team)

  def team_viewer?(%Socket{} = socket, team), do: Artemis.UserAccess.team_viewer?(socket.assigns.user, team)
  def team_viewer?(%Conn{} = conn, team), do: Artemis.UserAccess.team_viewer?(current_user(conn), team)
  def team_viewer?(user, team), do: Artemis.UserAccess.team_viewer?(user, team)
end
