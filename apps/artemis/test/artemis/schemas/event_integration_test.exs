defmodule Artemis.EventIntegrationTest do
  use Artemis.DataCase
  use ExUnit.Case, async: true

  import Ecto.Repo
  import Artemis.Factories

  alias Artemis.EventIntegration
  alias Artemis.EventTemplate

  @preload [:event_template]

  describe "attributes - constraints" do
    test "required associations" do
      params = params_for(:event_integration, integration_type: nil)

      {:error, changeset} =
        %EventIntegration{}
        |> EventIntegration.changeset(params)
        |> Repo.insert()

      assert errors_on(changeset) == %{integration_type: ["can't be blank"]}
    end

    test "integration type must in allowed integration types" do
      event_template = insert(:event_template)

      params =
        params_for(:event_integration, event_template: event_template, integration_type: "test-invalid-integration-type")

      {:error, changeset} =
        %EventIntegration{}
        |> EventIntegration.changeset(params)
        |> Repo.insert()

      assert errors_on(changeset) == %{integration_type: ["is invalid"]}
    end

    test "notification type must in allowed notification types" do
      event_template = insert(:event_template)

      params =
        params_for(:event_integration,
          event_template: event_template,
          notification_type: "test-invalid-notification-type"
        )

      {:error, changeset} =
        %EventIntegration{}
        |> EventIntegration.changeset(params)
        |> Repo.insert()

      assert errors_on(changeset) == %{notification_type: ["is invalid"]}
    end

    test "validations on settings map field - Slack Incoming Webhook" do
      # With Invalid Params

      invalid_fields = [
        integration_type: "Slack Incoming Webhook",
        settings: %{}
      ]

      params = params_for(:event_integration, invalid_fields)

      {:error, changeset} =
        %EventIntegration{}
        |> EventIntegration.changeset(params)
        |> Repo.insert()

      assert errors_on(changeset) == %{settings: ["Required fields: webhook_url"]}

      # With Valid Params

      valid_settings_field = %{
        webhook_url: "https://api.slack.com"
      }

      valid_fields = [
        integration_type: "Slack Incoming Webhook",
        settings: valid_settings_field
      ]

      params = params_for(:event_integration, valid_fields)

      {:ok, record} =
        %EventIntegration{}
        |> EventIntegration.changeset(params)
        |> Repo.insert()

      assert record.settings == valid_settings_field
    end
  end

  describe "associations - event_template" do
    setup do
      event_integration = insert(:event_integration)

      {:ok, event_integration: Repo.preload(event_integration, @preload)}
    end

    test "deleting association removes record", %{event_integration: event_integration} do
      assert Repo.get(EventTemplate, event_integration.event_template.id) != nil

      Repo.delete!(event_integration.event_template)

      assert Repo.get(EventTemplate, event_integration.event_template.id) == nil
      assert Repo.get(EventIntegration, event_integration.id) == nil
    end

    test "deleting record does not remove association", %{event_integration: event_integration} do
      assert Repo.get(EventTemplate, event_integration.event_template.id) != nil

      Repo.delete!(event_integration)

      assert Repo.get(EventTemplate, event_integration.event_template.id) != nil
      assert Repo.get(EventIntegration, event_integration.id) == nil
    end
  end
end
