defmodule Artemis.Factories do
  use ExMachina.Ecto, repo: Artemis.Repo

  # Factories

  def auth_provider_factory do
    %Artemis.AuthProvider{
      data: %{},
      type: Faker.Internet.slug(),
      uid: sequence(:uid, &"#{Faker.Internet.slug()}-#{&1}"),
      user: insert(:user)
    }
  end

  def feature_factory do
    %Artemis.Feature{
      active: false,
      name: sequence(:name, &"#{Faker.Name.name()}-#{&1}"),
      slug: sequence(:slug, &"#{Faker.Internet.slug()}-#{&1}")
    }
  end

  def permission_factory do
    %Artemis.Permission{
      name: sequence(:name, &"#{Faker.Name.name()}-#{&1}"),
      slug: sequence(:slug, &"#{Faker.Internet.slug()}-#{&1}")
    }
  end

  def role_factory do
    %Artemis.Role{
      name: sequence(:name, &"#{Faker.Name.name()}-#{&1}"),
      slug: sequence(:slug, &"#{Faker.Internet.slug()}-#{&1}")
    }
  end

  def standup_factory do
    %Artemis.Standup{
      date: DateTime.utc_now(),
      blockers: Faker.Lorem.sentence(),
      future: Faker.Lorem.sentence(),
      past: Faker.Lorem.sentence(),
      team: insert(:team),
      user: insert(:user)
    }
  end

  def team_factory do
    %Artemis.Team{
      active: false,
      name: sequence(:name, &"#{Faker.Name.name()}-#{&1}"),
      slug: sequence(:slug, &"#{Faker.Internet.slug()}-#{&1}")
    }
  end

  def user_factory do
    %Artemis.User{
      email: sequence(:slug, &"#{Faker.Internet.email()}-#{&1}"),
      first_name: Faker.Name.first_name(),
      last_name: Faker.Name.last_name(),
      name: sequence(:name, &"#{Faker.Name.name()}-#{&1}")
    }
  end

  def user_role_factory do
    %Artemis.UserRole{
      created_by: insert(:user),
      role: insert(:role),
      user: insert(:user)
    }
  end

  # Traits

  def with_auth_providers(%Artemis.User{} = user, number \\ 3) do
    insert_list(number, :auth_provider, user: user)
    user
  end

  def with_permission(%Artemis.User{} = user, slug) do
    permission = Artemis.Repo.get_by(Artemis.Permission, slug: slug) || insert(:permission, slug: slug)
    role = insert(:role, permissions: [permission])
    insert(:user_role, role: role, user: user)
    user
  end

  def with_permissions(%Artemis.Role{} = role, number \\ 3) do
    insert_list(number, :permission, roles: [role])
    role
  end

  def with_roles(%Artemis.Permission{} = permission, number \\ 3) do
    insert_list(number, :role, permissions: [permission])
    permission
  end

  def with_standups(resource, number \\ 3)
  def with_standups(%Artemis.Team{} = team, number) do
    insert_list(number, :standup, team: team)
    team
  end
  def with_standups(%Artemis.User{} = user, number) do
    insert_list(number, :standup, user: user)
    user
  end

  def with_user_roles(_record, number \\ 3)

  def with_user_roles(%Artemis.Role{} = role, number) do
    insert_list(number, :user_role, role: role)
    role
  end

  def with_user_roles(%Artemis.User{} = user, number) do
    insert_list(number, :user_role, user: user)
    user
  end
end
