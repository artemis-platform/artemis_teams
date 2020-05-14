defmodule Artemis.CreateEventAnswer do
  use Artemis.Context

  alias Artemis.EventAnswer
  alias Artemis.Helpers.Markdown
  alias Artemis.Repo

  def call!(params, user) do
    case call(params, user) do
      {:error, _} -> raise(Artemis.Context.Error, "Error creating event answer")
      {:ok, result} -> result
    end
  end

  def call(params, user) do
    with_transaction(fn ->
      params
      |> insert_record
      |> Event.broadcast("event-answer:created", params, user)
    end)
  end

  defp insert_record(params) do
    params = create_params(params)

    %EventAnswer{}
    |> EventAnswer.changeset(params)
    |> Repo.insert()
  end

  defp create_params(params) do
    params
    |> Artemis.Helpers.keys_to_strings()
    |> maybe_update_value_html()
    |> maybe_update_value_number()
  end

  defp maybe_update_value_html(%{"value" => value} = params) when is_bitstring(value) do
    value_html = Markdown.to_html!(value)

    Map.put(params, "value_html", value_html)
  rescue
    _ -> params
  end

  defp maybe_update_value_html(params), do: params

  defp maybe_update_value_number(%{"type" => type, "value" => value} = params) do
    numeric_types = ["number"]

    case Enum.member?(numeric_types, type) do
      true -> Map.put(params, "value_number", value)
      false -> params
    end
  end

  defp maybe_update_value_number(params), do: params
end
