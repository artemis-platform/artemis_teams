defmodule Artemis.ListTeamStandups do
  use Artemis.Context

  import Artemis.Helpers.Search
  import Ecto.Query

  alias Artemis.Standup
  alias Artemis.Repo
  alias Artemis.Team

  defmodule Entry do
    defstruct [
      :id,
      :date,
      :count,
      :earliest,
      :latest
    ]
  end

  # TODO: require team id?
  #   Or use `ListTeams` to filter available teams and pipe into `where ... in` filter?

  def call(params \\ %{}, user) do
    Standup
    |> group_by([s], [s.date])
    |> select([s], %Entry{date: s.date, count: count(s.id), earliest: min(s.inserted_at), latest: max(s.inserted_at)})
    |> Repo.all()
    |> Enum.map(&struct(&1, id: Date.to_string(&1.date)))
    # |> Enum.reduce(%{}, &Map.put(&2, hd(&1), tl(&1)))
    # Event
    # |> join(:left, [event], event_type in assoc(event, :event_type))
    # |> where([..., evt], evt.slug == "iaas_invoice")
    # |> group_by([ev], [ev.project_id])
    # |> select([ev], [ev.project_id, max(ev.name), sum(ev.invoice_amount), max(ev.started_at), min(ev.started_at)])
    # |> Repo.all
    # |> Enum.reduce(%{}, &Map.put(&2, hd(&1), tl(&1)))
  end

  # @default_order "date"
  # @default_page_size 25
  # @default_preload []

  # def call(params \\ %{}, user) do
  #   params = default_params(params)

  #   Team
  #   |> preload(^Map.get(params, "preload"))
  #   |> search_filter(params)
  #   |> order_query(params)
  #   |> restrict_access(user)
  #   |> get_records(params)
  # end

  # defp default_params(params) do
  #   params
  #   |> Artemis.Helpers.keys_to_strings()
  #   |> Map.put_new("order", @default_order)
  #   |> Map.put_new("page_size", @default_page_size)
  #   |> Map.put_new("preload", @default_preload)
  # end

  # defp get_records(query, %{"paginate" => true} = params), do: Repo.paginate(query, pagination_params(params))
  # defp get_records(query, _params), do: Repo.all(query)

  # defp restrict_access(query, user) do
  #   cond do
  #     has?(user, "teams:access:all") -> query
  #     has?(user, "teams:access:associated") -> restrict_associated_access(query, user)
  #     true -> where(query, [u], is_nil(u.id))
  #   end
  # end

  # defp restrict_associated_access(query, user) do
  #   query
  #   |> join(:left, [team], team_users in assoc(team, :team_users))
  #   |> where([..., tu], tu.user_id == ^user.id)
  # end
end
