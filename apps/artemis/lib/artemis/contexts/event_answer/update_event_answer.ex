defmodule Artemis.UpdateEventAnswer do
  use Artemis.Context

  alias Artemis.EventAnswer
  alias Artemis.GetEventAnswer
  alias Artemis.Helpers.Markdown
  alias Artemis.Repo

  def call!(id, params, user) do
    case call(id, params, user) do
      {:error, _} -> raise(Artemis.Context.Error, "Error updating event answer")
      {:ok, result} -> result
    end
  end

  def call(id, params, user) do
    with_transaction(fn ->
      id
      |> get_record(user)
      |> update_record(params)
      |> Event.broadcast("event-answer:updated", params, user)
    end)
  end

  def get_record(%{id: id}, user), do: get_record(id, user)
  def get_record(id, user), do: GetEventAnswer.call(id, user)

  defp update_record(nil, _params), do: {:error, "Record not found"}

  defp update_record(record, params) do
    params = update_params(record, params)

    record
    |> EventAnswer.changeset(params)
    |> Repo.update()
  end

  defp update_params(_record, params) do
    params
    |> Artemis.Helpers.keys_to_strings()
    |> maybe_update_value_html()
  end

  defp maybe_update_value_html(%{"value" => value} = params) when is_bitstring(value) do
    value_html = Markdown.to_html!(value)

    Map.put(params, "value_html", value_html)
  rescue
    _ -> params
  end

  defp maybe_update_value_html(params), do: params
end
