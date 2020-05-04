defmodule Artemis.EventTemplateTest do
  use Artemis.DataCase
  use ExUnit.Case, async: true

  import Ecto.Repo
  import Artemis.Factories

  alias Artemis.EventIntegration
  alias Artemis.EventQuestion
  alias Artemis.EventTemplate
  alias Artemis.Team

  @preload [:event_integrations, :event_questions, :team]

  describe "attributes - constraints" do
    test "required associations" do
      params = params_for(:event_template)

      {:error, changeset} =
        %EventTemplate{}
        |> EventTemplate.changeset(params)
        |> Repo.insert()

      assert errors_on(changeset) == %{team_id: ["can't be blank"]}
    end
  end

  describe "associations - event integrations" do
    setup do
      event_template = insert(:event_template)

      insert_list(3, :event_integration, event_template: event_template)

      {:ok, event_template: Repo.preload(event_template, @preload)}
    end

    test "cannot update associations through parent", %{event_template: event_template} do
      new_event_integration = insert(:event_integration, event_template: event_template)

      event_template =
        EventTemplate
        |> preload(^@preload)
        |> Repo.get(event_template.id)

      assert length(event_template.event_integrations) == 4

      {:ok, updated} =
        event_template
        |> EventTemplate.changeset(%{event_integrations: [new_event_integration]})
        |> Repo.update()

      updated = Repo.preload(updated, @preload)

      assert length(updated.event_integrations) == 4
    end

    test "deleting association does not remove record", %{event_template: event_template} do
      assert Repo.get(EventTemplate, event_template.id) != nil
      assert length(event_template.event_integrations) == 3

      Enum.map(event_template.event_integrations, &Repo.delete(&1))

      event_template =
        EventTemplate
        |> preload(^@preload)
        |> Repo.get(event_template.id)

      assert Repo.get(EventTemplate, event_template.id) != nil
      assert length(event_template.event_integrations) == 0
    end

    test "deleting record deletes associations", %{event_template: event_template} do
      assert Repo.get(EventTemplate, event_template.id) != nil
      assert length(event_template.event_integrations) == 3

      Enum.map(event_template.event_integrations, fn event_integration ->
        assert Repo.get(EventIntegration, event_integration.id).event_template_id == event_template.id
      end)

      Repo.delete(event_template)

      assert Repo.get(EventTemplate, event_template.id) == nil

      Enum.map(event_template.event_integrations, fn event_integration ->
        assert Repo.get(EventIntegration, event_integration.id) == nil
      end)
    end
  end

  describe "associations - event questions" do
    setup do
      event_template = insert(:event_template)

      insert_list(3, :event_question, event_template: event_template)

      {:ok, event_template: Repo.preload(event_template, @preload)}
    end

    test "cannot update associations through parent", %{event_template: event_template} do
      new_event_question = insert(:event_question, event_template: event_template)

      event_template =
        EventTemplate
        |> preload(^@preload)
        |> Repo.get(event_template.id)

      assert length(event_template.event_questions) == 4

      {:ok, updated} =
        event_template
        |> EventTemplate.changeset(%{event_questions: [new_event_question]})
        |> Repo.update()

      updated = Repo.preload(updated, @preload)

      assert length(updated.event_questions) == 4
    end

    test "deleting association does not remove record", %{event_template: event_template} do
      assert Repo.get(EventTemplate, event_template.id) != nil
      assert length(event_template.event_questions) == 3

      Enum.map(event_template.event_questions, &Repo.delete(&1))

      event_template =
        EventTemplate
        |> preload(^@preload)
        |> Repo.get(event_template.id)

      assert Repo.get(EventTemplate, event_template.id) != nil
      assert length(event_template.event_questions) == 0
    end

    test "deleting record deletes associations", %{event_template: event_template} do
      assert Repo.get(EventTemplate, event_template.id) != nil
      assert length(event_template.event_questions) == 3

      Enum.map(event_template.event_questions, fn event_question ->
        assert Repo.get(EventQuestion, event_question.id).event_template_id == event_template.id
      end)

      Repo.delete(event_template)

      assert Repo.get(EventTemplate, event_template.id) == nil

      Enum.map(event_template.event_questions, fn event_question ->
        assert Repo.get(EventQuestion, event_question.id) == nil
      end)
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
