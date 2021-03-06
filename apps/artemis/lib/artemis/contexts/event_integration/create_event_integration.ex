defmodule Artemis.CreateEventIntegration do
  use Artemis.Context

  alias Artemis.EventIntegration
  alias Artemis.Helpers.Markdown
  alias Artemis.Repo

  def call!(params, user) do
    case call(params, user) do
      {:error, _} -> raise(Artemis.Context.Error, "Error creating event_integration")
      {:ok, result} -> result
    end
  end

  def call(params, user) do
    with_transaction(fn ->
      params
      |> insert_record
      |> Event.broadcast("event_integration:created", params, user)
    end)
  end

  defp insert_record(params) do
    params = create_params(params)

    %EventIntegration{}
    |> EventIntegration.changeset(params)
    |> Repo.insert()
  end

  defp create_params(params) do
    params
    |> Artemis.Helpers.keys_to_strings()
    |> maybe_update_description_html()
  end

  defp maybe_update_description_html(%{"description" => description} = params) do
    value = Markdown.to_html!(description)

    Map.put(params, "description_html", value)
  end

  defp maybe_update_description_html(params), do: params
end
