defmodule Artemis.EventIntegration do
  use Artemis.Schema
  use Artemis.Schema.SQL
  use Assoc.Schema, repo: Artemis.Repo

  schema "event_integrations" do
    field :active, :boolean, default: true
    field :integration_type, :string
    field :name, :string
    field :notification_type, :string
    field :settings, :map

    belongs_to :event_template, Artemis.EventTemplate, on_replace: :delete

    has_one :team, through: [:event_template, :team]

    timestamps()
  end

  # Callbacks

  def updatable_fields,
    do: [
      :active,
      :name,
      :integration_type,
      :notification_type,
      :settings,
      :event_template_id
    ]

  def required_fields,
    do: [
      :integration_type,
      :notification_type
    ]

  def updatable_associations,
    do: [
      event_template: Artemis.EventTemplate
    ]

  def event_log_fields,
    do: [
      :id,
      :integration_type,
      :name,
      :notification_type
    ]

  def allowed_integration_types,
    do: [
      "Email",
      "Slack Incoming Webhook"
    ]

  def allowed_notification_types,
    do: [
      "Reminder",
      "Summary"
    ]

  # Changesets

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, updatable_fields())
    |> validate_required(required_fields())
    |> validate_inclusion(:integration_type, allowed_integration_types())
    |> validate_inclusion(:notification_type, allowed_notification_types())
    |> validate_settings()
    |> foreign_key_constraint(:event_template_id)
  end

  # Validators

  defp validate_settings(changeset) do
    integration_type = Ecto.Changeset.get_field(changeset, :integration_type)

    settings =
      changeset
      |> Ecto.Changeset.get_field(:settings, %{})
      |> Artemis.Helpers.keys_to_strings()

    validate_settings(changeset, integration_type, settings)
  end

  defp validate_settings(changeset, "Slack Incoming Webhook", settings) do
    required_fields = [
      "webhook_url"
    ]

    missing_fields = get_missing_fields(settings, required_fields)

    case length(missing_fields) > 0 do
      true -> add_error(changeset, :settings, "#{Enum.join(missing_fields)} is required")
      false -> changeset
    end
  end

  defp validate_settings(changeset, _, _), do: changeset

  # Validation Helpers

  defp get_missing_fields(map, fields) do
    Enum.reduce(fields, [], fn field, acc ->
      value = Map.get(map, field)
      present? = Artemis.Helpers.present?(value)

      case present? do
        true -> acc
        false -> [field | acc]
      end
    end)
  end
end
