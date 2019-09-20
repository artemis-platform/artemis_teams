defmodule Artemis.EventTemplateTest do
  use Artemis.DataCase
  use ExUnit.Case, async: true

  import Ecto.Repo
  import Artemis.Factories

  alias Artemis.EventTemplate
  alias Artemis.Team

  @preload [:team]

  describe "attributes - constraints" do
    test "slug must be unique" do
      slug = "uniqueness-constraint-slug"
      team1 = insert(:team)
      team2 = insert(:team)

      insert(:event_template, slug: slug, team: team1)

      # Successfully creates a record with a different slug for the same team

      insert(:event_template, team: team1)

      # Successfully creates a record with the same slug for a different team

      insert(:event_template, slug: slug, team: team2)

      # Raises when the same slug is used for the same team

      assert_raise Ecto.ConstraintError, fn ->
        insert(:event_template, slug: slug, team: team1)
      end
    end
  end

  describe "associations - team" do
    setup do
      event_template = insert(:event_template)

      {:ok, event_template: Repo.preload(event_template, @preload)}
    end

    test "deleting association removes record", %{event_template: event_template} do
      assert Repo.get(Team, event_template.team.id) != nil

      Repo.delete!(event_template.team)

      assert Repo.get(Team, event_template.team.id) == nil
      assert Repo.get(EventTemplate, event_template.id) == nil
    end

    test "deleting record does not remove association", %{event_template: event_template} do
      assert Repo.get(Team, event_template.team.id) != nil

      Repo.delete!(event_template)

      assert Repo.get(Team, event_template.team.id) != nil
      assert Repo.get(EventTemplate, event_template.id) == nil
    end
  end
end
