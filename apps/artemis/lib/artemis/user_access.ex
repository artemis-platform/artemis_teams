defmodule Artemis.UserAccess do
  alias Artemis.Repo
  alias Artemis.Team
  alias Artemis.User

  # User Permissions - Boolean Queries

  def has?(%User{} = user, permission) when is_bitstring(permission), do: has_any?(user, [permission])
  def has?(_, _), do: false

  def has_any?(%User{} = user, permission) when is_bitstring(permission), do: has_any?(user, [permission])

  def has_any?(%User{} = user, permissions) when is_list(permissions) do
    permissions
    |> MapSet.new()
    |> MapSet.disjoint?(user_permissions(user))
    |> Kernel.not()
  end

  def has_any?(_, _), do: false

  def has_all?(%User{} = user, permission) when is_bitstring(permission), do: has_all?(user, [permission])
  def has_all?(%User{} = _user, permissions) when length(permissions) == 0, do: false

  def has_all?(%User{} = user, permissions) when is_list(permissions) do
    permissions
    |> MapSet.new()
    |> MapSet.subset?(user_permissions(user))
  end

  def has_all?(_, _), do: false

  # User Teams - Boolean Queries

  def in_team?(%User{} = user, %Team{id: id}), do: in_team?(user, id)

  def in_team?(%User{} = user, team_id) do
    team_id = Artemis.Helpers.to_integer(team_id)

    Enum.any?(user_teams(user), &(&1.team_id == team_id))
  end

  def team_admin?(user, team), do: has_team_type?(user, team, "admin")

  def team_member?(user, team), do: has_team_type?(user, team, "member")

  def team_viewer?(user, team), do: has_team_type?(user, team, "viewer")

  def has_team_type?(%User{} = user, %Team{id: id}, type), do: has_team_type?(user, id, type)

  def has_team_type?(%User{} = user, team_id, type) do
    team_id = Artemis.Helpers.to_integer(team_id)

    Enum.any?(user_teams(user), &(&1.team_id == team_id && &1.type == type))
  end

  # Helpers

  defp user_permissions(user) do
    user
    |> Repo.preload([:permissions])
    |> Map.get(:permissions)
    |> Enum.map(& &1.slug)
    |> MapSet.new()
  end

  defp user_teams(user) do
    user
    |> Repo.preload([:user_teams])
    |> Map.get(:user_teams)
  end
end
