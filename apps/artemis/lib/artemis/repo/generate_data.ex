defmodule Artemis.Repo.GenerateData do
  import Ecto.Query

  alias Artemis.Feature
  alias Artemis.Permission
  alias Artemis.Repo
  alias Artemis.Role
  alias Artemis.Tag
  alias Artemis.User
  alias Artemis.UserRole

  @moduledoc """
  Defines the minimum data required for the application to run.

  Should be run each time new code is deployed to ensure application integrity.

  To prevent data collisions, each section must be idempotent - only attempting
  to create data when it is not present.

  Note: Filler data used for development, qa, test and demo environments should
  be defined in `Artemis.Repo.GenerateFillerData` instead.
  """

  def call() do
    # Features

    features = [
      %{slug: "global-search", name: "Global Search", active: true}
    ]

    Enum.map(features, fn params ->
      case Repo.get_by(Feature, slug: params.slug) do
        nil ->
          %Feature{}
          |> Feature.changeset(params)
          |> Repo.insert!()

        _ ->
          :ok
      end
    end)

    # Roles

    roles = [
      %{slug: "developer", name: "Site Developer"},
      %{slug: "default", name: "Default"}
    ]

    Enum.map(roles, fn params ->
      case Repo.get_by(Role, slug: params.slug) do
        nil ->
          %Role{}
          |> Role.changeset(params)
          |> Repo.insert!()

        _ ->
          :ok
      end
    end)

    # Permissions

    admin_only = "Should be restricted to administrators"

    permissions = [
      %{slug: "comments:access:all", name: "Comments - Access All", description: admin_only},
      %{slug: "comments:access:self", name: "Comments - Access Self"},
      %{slug: "event-logs:access:all", name: "Event Logs - Access All", description: admin_only},
      %{slug: "event-logs:access:self", name: "Event Logs - Access Self"},
      %{slug: "event-logs:list", name: "Event Logs - List"},
      %{slug: "event-logs:show", name: "Event Logs - Show"},
      %{slug: "event-templates:create", name: "Event Templates - Create"},
      %{slug: "event-templates:list", name: "Event Templates - List"},
      %{slug: "event-templates:delete", name: "Event Templates - Delete"},
      %{slug: "event-templates:show", name: "Event Templates - Show"},
      %{slug: "event-templates:update", name: "Event Templates - Update"},
      %{slug: "features:create", name: "Features - Create"},
      %{slug: "features:delete", name: "Features - Delete"},
      %{slug: "features:list", name: "Features - List"},
      %{slug: "features:show", name: "Features - Show"},
      %{slug: "features:update", name: "Features - Update"},
      %{slug: "http-request-logs:access:all", name: "HTTP Request Logs - Access All", description: admin_only},
      %{slug: "http-request-logs:access:self", name: "HTTP Request Logs - Access Self"},
      %{slug: "http-request-logs:list", name: "HTTP Request Logs - List"},
      %{slug: "http-request-logs:show", name: "HTTP Request Logs - Show"},
      %{slug: "permissions:create", name: "Permissions - Create"},
      %{slug: "permissions:delete", name: "Permissions - Delete"},
      %{slug: "permissions:list", name: "Permissions - List"},
      %{slug: "permissions:show", name: "Permissions - Show"},
      %{slug: "permissions:update", name: "Permissions - Update"},
      %{slug: "roles:create", name: "Roles - Create"},
      %{slug: "roles:delete", name: "Roles - Delete"},
      %{slug: "roles:list", name: "Roles - List"},
      %{slug: "roles:show", name: "Roles - Show"},
      %{slug: "roles:update", name: "Roles - Update"},
      %{slug: "sessions:access:all", name: "Sessions - Access All", description: admin_only},
      %{slug: "sessions:access:self", name: "Sessions - Access Self"},
      %{slug: "sessions:list", name: "Sessions - List"},
      %{slug: "sessions:show", name: "Sessions - Show"},
      %{slug: "tags:create", name: "Tags - Global Create", description: admin_only},
      %{slug: "tags:delete", name: "Tags - Global Delete", description: admin_only},
      %{slug: "tags:list", name: "Tags - Global List", description: admin_only},
      %{slug: "tags:show", name: "Tags - Global Show", description: admin_only},
      %{slug: "tags:update", name: "Tags - Global Update", description: admin_only},
      %{slug: "teams:access:all", name: "Teams - Access All"},
      %{slug: "teams:access:associated", name: "Teams - Access Associated"},
      %{slug: "teams:create", name: "Teams - Create"},
      %{slug: "teams:delete", name: "Teams - Delete"},
      %{slug: "teams:list", name: "Teams - List"},
      %{slug: "teams:show", name: "Teams - Show"},
      %{slug: "teams:update", name: "Teams - Update"},
      %{slug: "team-users:create", name: "Team Users - Create"},
      %{slug: "team-users:list", name: "Team Users - List"},
      %{slug: "team-users:delete", name: "Team Users - Delete"},
      %{slug: "team-users:show", name: "Team Users - Show"},
      %{slug: "team-users:update", name: "Team Users - Update"},
      %{slug: "user-anonymizations:create", name: "User Anonymizations - Create"},
      %{slug: "user-impersonations:create", name: "User Impersonations - Create"},
      %{slug: "users:access:all", name: "Users - Access All", description: admin_only},
      %{slug: "users:access:self", name: "Users - Access Self"},
      %{slug: "users:create", name: "Users - Create"},
      %{slug: "users:delete", name: "Users - Delete"},
      %{slug: "users:list", name: "Users - List"},
      %{slug: "users:show", name: "Users - Show"},
      %{slug: "users:update", name: "Users - Update"}
    ]

    Enum.map(permissions, fn params ->
      case Repo.get_by(Permission, slug: params.slug) do
        nil ->
          %Permission{}
          |> Permission.changeset(params)
          |> Repo.insert!()

        _ ->
          :ok
      end
    end)

    # Role Permissions - Developer Role

    permissions = Repo.all(Permission)

    role =
      Role
      |> preload([:permissions, :user_roles])
      |> Repo.get_by(slug: "developer")

    role
    |> Role.associations_changeset(%{permissions: permissions})
    |> Repo.update!()

    # Role Permissions - Default Role

    permission_slugs = [
      "event-logs:access:self",
      "users:access:self",
      "users:show"
    ]

    permissions =
      Permission
      |> where([p], p.slug in ^permission_slugs)
      |> Repo.all()

    role =
      Role
      |> preload([:permissions, :user_roles])
      |> Repo.get_by(slug: "default")

    role
    |> Role.associations_changeset(%{permissions: permissions})
    |> Repo.update!()

    # Users

    users = [
      Application.fetch_env!(:artemis, :users)[:root_user],
      Application.fetch_env!(:artemis, :users)[:system_user]
    ]

    Enum.map(users, fn params ->
      case Repo.get_by(User, email: params.email) do
        nil ->
          params =
            params
            |> Map.put(:client_key, Artemis.Helpers.random_string(30))
            |> Map.put(:client_secret, Artemis.Helpers.random_string(100))

          %User{}
          |> User.changeset(params)
          |> Repo.insert!()

        _ ->
          :ok
      end
    end)

    # User Roles

    role = Repo.get_by!(Role, slug: "developer")

    user_emails = [
      Application.fetch_env!(:artemis, :users)[:root_user].email,
      Application.fetch_env!(:artemis, :users)[:system_user].email
    ]

    users = Enum.map(user_emails, &Repo.get_by!(User, email: &1))

    Enum.map(users, fn user ->
      case Repo.get_by(UserRole, role_id: role.id, user_id: user.id) do
        nil ->
          params = %{
            created_by_id: user.id,
            role_id: role.id,
            user_id: user.id
          }

          %UserRole{}
          |> UserRole.changeset(params)
          |> Repo.insert!()

        _ ->
          :ok
      end
    end)

    # Tags

    tags = []

    Enum.map(tags, fn params ->
      case Repo.get_by(Tag, slug: params.slug, type: params.type) do
        nil ->
          %Tag{}
          |> Tag.changeset(params)
          |> Repo.insert!()

        _ ->
          :ok
      end
    end)

    # Return Value

    {:ok, []}
  end
end
