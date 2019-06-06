defmodule Artemis.ListTeamStandups do
  use Artemis.Context

  import Artemis.Helpers.Filter
  import Ecto.Query

  alias Artemis.Repo
  alias Artemis.Standup

  defmodule Entry do
    defstruct [
      :id,
      :date,
      :count,
      :earliest,
      :latest
    ]
  end

  @default_order "date"

  def call(params \\ %{}, user) do
    params = default_params(params)

    Standup
    |> order_query(params)
    |> filter_query(params, user)
    |> get_records(params)
    |> process_records()
  end

  defp default_params(params) do
    params
    |> Artemis.Helpers.keys_to_strings()
    |> Map.put_new("order", @default_order)
  end

  defp filter_query(query, %{"filters" => filters}, _user) when is_map(filters) do
    Enum.reduce(filters, query, fn {key, value}, acc ->
      filter(acc, key, value)
    end)
  end

  defp filter_query(query, _params, _user), do: query

  defp filter(query, _key, nil), do: query
  defp filter(query, _key, ""), do: query
  defp filter(query, "team_id", value), do: where(query, [s], s.team_id in ^split(value))
  defp filter(query, _key, _value), do: query

  defp get_records(query, _params) do
    query
    |> distinct(true)
    |> group_by([s], [s.date])
    |> select([s], %Entry{date: s.date, count: count(s.id), earliest: min(s.inserted_at), latest: max(s.inserted_at)})
    |> Repo.all()
  end

  defp process_records(records) do
    Enum.map(records, fn record ->
      Map.put(record, :id, Date.to_string(record.date))
    end)
  end
end