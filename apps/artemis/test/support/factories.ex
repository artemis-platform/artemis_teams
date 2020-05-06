defmodule Artemis.Factories do
  use ExMachina.Ecto, repo: Artemis.Repo

  # Factories

  def auth_provider_factory do
    %Artemis.AuthProvider{
      data: %{},
      type: Faker.Internet.slug(),
      uid: sequence(:uid, &"#{Faker.Internet.slug()}-#{&1}"),
      user: build(:user)
    }
  end

  def comment_factory do
    body = Faker.Lorem.paragraph()

    %Artemis.Comment{
      body: body,
      body_html: body,
      resource_id: "1",
      resource_type: "WikiPage",
      topic: Faker.Name.name(),
      title: sequence(:title, &"#{Faker.Name.name()}-#{&1}"),
      user: build(:user)
    }
  end

  def event_answer_factory do
    %Artemis.EventAnswer{
      date: Date.utc_today(),
      type: Enum.random(Artemis.EventAnswer.allowed_types()),
      value: Faker.Lorem.paragraph(),
      event_question: build(:event_question),
      project: build(:project),
      user: build(:user)
    }
  end

  def event_integration_factory do
    %Artemis.EventIntegration{
      active: true,
      integration_type: "Slack Incoming Webhook",
      name: sequence(:name, &"#{Faker.Name.name()}-#{&1}"),
      notification_type: Enum.random(Artemis.EventIntegration.allowed_notification_types()),
      settings: %{webhook_url: "https://api.slack.com"},
      event_template: build(:event_template)
    }
  end

  def event_question_factory do
    description = Faker.Lorem.paragraph()

    %Artemis.EventQuestion{
      active: true,
      description: description,
      description_html: description,
      order: 1,
      multiple: true,
      required: true,
      title: sequence(:title, &"#{Faker.Name.name()}-#{&1}"),
      type: Enum.random(Artemis.EventQuestion.allowed_types()),
      event_template: build(:event_template)
    }
  end

  def event_template_factory do
    description = Faker.Lorem.paragraph()

    %Artemis.EventTemplate{
      active: true,
      description: description,
      description_html: description,
      title: sequence(:title, &"#{Faker.Name.name()}-#{&1}"),
      team: build(:team)
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

  def project_factory do
    description = Faker.Lorem.paragraph()

    %Artemis.Project{
      active: true,
      description: description,
      description_html: description,
      title: sequence(:title, &"#{Faker.Name.name()}-#{&1}"),
      team: build(:team)
    }
  end

  def role_factory do
    %Artemis.Role{
      name: sequence(:name, &"#{Faker.Name.name()}-#{&1}"),
      slug: sequence(:slug, &"#{Faker.Internet.slug()}-#{&1}")
    }
  end

  def system_task_factory do
    %Artemis.SystemTask{
      extra_params: %{
        "reason" => "Testing"
      },
      type: "delete_all_comments"
    }
  end

  def tag_factory do
    %Artemis.Tag{
      description: Faker.Lorem.paragraph(),
      name: sequence(:name, &"#{Faker.Name.name()}-#{&1}"),
      slug: sequence(:slug, &"#{Faker.Internet.slug()}-#{&1}"),
      type: sequence(:type, &"#{Faker.Internet.slug()}-#{&1}")
    }
  end

  def team_factory do
    %Artemis.Team{
      description: Faker.Lorem.paragraph(),
      name: sequence(:name, &"#{Faker.Name.name()}-#{&1}")
    }
  end

  def user_factory do
    %Artemis.User{
      email: sequence(:email, &"#{Faker.Internet.email()}-#{&1}"),
      first_name: Faker.Name.first_name(),
      last_name: Faker.Name.last_name(),
      name: sequence(:name, &"#{Faker.Name.name()}-#{&1}"),
      username: sequence(:username, &"#{Faker.Address.country_code()}-#{&1}")
    }
  end

  def user_role_factory do
    %Artemis.UserRole{
      created_by: build(:user),
      role: build(:role),
      user: build(:user)
    }
  end

  def user_team_factory do
    %Artemis.UserTeam{
      created_by: build(:user),
      team: build(:team),
      type: Enum.random(Artemis.UserTeam.allowed_types()),
      user: build(:user)
    }
  end

  def wiki_page_factory do
    %Artemis.WikiPage{
      body: Faker.Lorem.paragraph(),
      section: Faker.Name.name(),
      slug: sequence(:slug, &"#{Faker.Internet.slug()}-#{&1}"),
      title: sequence(:title, &"#{Faker.Name.name()}-#{&1}"),
      user: build(:user),
      weight: :rand.uniform(100)
    }
  end

  def wiki_revision_factory do
    %Artemis.WikiRevision{
      body: Faker.Lorem.paragraph(),
      section: Faker.Name.name(),
      slug: sequence(:slug, &"#{Faker.Internet.slug()}-#{&1}"),
      title: sequence(:title, &"#{Faker.Name.name()}-#{&1}"),
      user: build(:user),
      weight: :rand.uniform(100),
      wiki_page: build(:wiki_page)
    }
  end

  # Traits

  def with_auth_providers(%Artemis.User{} = user, number \\ 3) do
    insert_list(number, :auth_provider, user: user)
    user
  end

  def with_comments(%Artemis.User{} = user, number \\ 3) do
    insert_list(number, :comment, user: user)
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

  def with_user_roles(_record, number \\ 3)

  def with_user_roles(%Artemis.Role{} = role, number) do
    insert_list(number, :user_role, role: role)
    role
  end

  def with_user_roles(%Artemis.User{} = user, number) do
    insert_list(number, :user_role, user: user)
    user
  end

  def with_wiki_page(%Artemis.Tag{} = tag) do
    insert(:wiki_page, tags: [tag])
    tag
  end

  def with_wiki_pages(%Artemis.User{} = user, number \\ 3) do
    insert_list(number, :wiki_page, user: user)
    user
  end

  def with_wiki_revisions(%Artemis.User{} = user, number \\ 3) do
    insert_list(number, :wiki_revision, user: user)
    user
  end
end
