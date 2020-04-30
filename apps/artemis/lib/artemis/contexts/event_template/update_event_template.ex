defmodule Artemis.UpdateEventTemplate do
  use Artemis.Context

  alias Artemis.EventTemplate
  alias Artemis.GetEventTemplate
  alias Artemis.Helpers.Markdown
  alias Artemis.Repo

  def call!(id, params, user) do
    case call(id, params, user) do
      {:error, _} -> raise(Artemis.Context.Error, "Error updating event_template")
      {:ok, result} -> result
    end
  end

  def call(id, params, user) do
    with_transaction(fn ->
      id
      |> get_record(user)
      |> update_record(params)
      |> Event.broadcast("event_template:updated", params, user)
    end)
  end

  def get_record(%{id: id}, user), do: get_record(id, user)
  def get_record(id, user), do: GetEventTemplate.call(id, user)

  defp update_record(nil, _params), do: {:error, "Record not found"}

  defp update_record(record, params) do
    params = update_params(record, params)

    record
    |> EventTemplate.changeset(params)
    |> Repo.update()
  end

  defp update_params(_record, params) do
    params
    |> Artemis.Helpers.keys_to_strings()
    |> maybe_update_categories()
    |> maybe_update_description_html()
  end

  defp maybe_update_categories(%{"categories" => categories} = params) when is_bitstring(categories) do
    value =
      categories
      |> String.replace("\r", "")
      |> String.split("\n")

    Map.put(params, "categories", value)
  end

  defp maybe_update_categories(params), do: params

  defp maybe_update_description_html(%{"description" => description} = params) do
    value = Markdown.to_html!(description)

    Map.put(params, "description_html", value)
  end

  defp maybe_update_description_html(params), do: params
end
