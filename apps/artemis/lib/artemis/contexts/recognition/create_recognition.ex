defmodule Artemis.CreateRecognition do
  use Artemis.Context
  use Assoc.Updater, repo: Artemis.Repo

  alias Artemis.Helpers.Markdown
  alias Artemis.Repo
  alias Artemis.Recognition

  def call!(params, user) do
    case call(params, user) do
      {:error, _} -> raise(Artemis.Context.Error, "Error creating recognition")
      {:ok, result} -> result
    end
  end

  def call(params, user) do
    with_transaction(fn ->
      params
      |> insert_record
      |> update_associations(params)
      |> Event.broadcast("recognition:created", params, user)
    end)
  end

  defp insert_record(params) do
    params = create_params(params)

    %Recognition{}
    |> Recognition.changeset(params)
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
