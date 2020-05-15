defmodule Artemis.UpdateEventInstance do
  use Artemis.Context

  alias Artemis.CreateEventAnswer
  alias Artemis.DeleteEventAnswer
  alias Artemis.EventAnswer
  alias Artemis.Repo
  alias Artemis.UpdateEventAnswer

  def call!(params, event_questions, user) do
    case call(params, event_questions, user) do
      {:error, _} -> raise(Artemis.Context.Error, "Error updating event instance")
      {:ok, result} -> result
    end
  end

  def call(params, event_questions, user) do
    Repo.Helpers.with_transaction(fn ->
      params
      |> record_event_answers(event_questions, user)
      |> parse_results()
    end)
  end

  defp record_event_answers(event_answer_params, event_questions, user) do
    event_answer_params
    |> filter_event_answer_params(event_questions)
    |> process_event_answer_params()
    |> Enum.map(&record_event_answer(&1, user))
  end

  defp parse_results(results) do
    error? = Enum.any?(results, &(elem(&1, 0) == :error))
    changesets = Enum.map(results, &elem(&1, 1))

    case error? do
      true -> {:error, changesets}
      false -> {:ok, changesets}
    end
  end

  # Helpers

  defp filter_event_answer_params(event_answer_params, event_questions) do
    event_answer_params
    |> Enum.reduce([], fn params, acc ->
      event_question = get_event_question(params, event_questions)

      required? = event_question.required

      multiple? = event_question.multiple
      single? = !multiple?

      delete_present? = Map.get(params, "delete") == "true"
      active? = !delete_present?

      value_present? =
        params
        |> Map.get("value")
        |> Artemis.Helpers.present?()

      id_present? =
        params
        |> Map.get("id")
        |> Artemis.Helpers.present?()

      cond do
        single? && required? -> [params | acc]
        single? && id_present? -> [params | acc]
        single? && value_present? -> [params | acc]
        multiple? && required? && active? -> [params | acc]
        multiple? && id_present? -> [params | acc]
        multiple? && value_present? && active? -> [params | acc]
        true -> acc
      end
    end)
    |> Enum.reverse()
  end

  defp process_event_answer_params(event_answer_params) do
    denominators = get_event_answer_percent_denominators(event_answer_params)

    Enum.map(event_answer_params, fn params ->
      value_percent = get_event_answer_percent_denominator_value(denominators, params)

      Map.put(params, "value_percent", value_percent)
    end)
  end

  defp get_event_answer_percent_denominators(event_answer_params) do
    Enum.reduce(event_answer_params, %{}, fn params, acc ->
      key = get_event_answer_percent_denominator_key(params)
      current = get_in(acc, key) || Decimal.new(0)
      new = get_event_answer_value_decimal(params)
      to_be_deleted? = Map.get(params, "delete") == "true"

      result =
        case to_be_deleted? do
          true -> current
          false -> Decimal.add(current, new)
        end

      Artemis.Helpers.deep_put(acc, key, result)
    end)
  end

  defp get_event_answer_percent_denominator_key(params) do
    [
      params["event_question_id"],
      params["user_id"]
    ]
  end

  defp get_event_answer_value_decimal(%{"value" => value}) do
    Decimal.new(value)
  rescue
    _e in Decimal.Error -> Decimal.new(0)
    _e in FunctionClauseErrorr -> Decimal.new(0)
  end

  defp get_event_answer_percent_denominator_value(denominators, params) do
    key = get_event_answer_percent_denominator_key(params)
    denominator = get_in(denominators, key) || Decimal.new(0)
    current = get_event_answer_value_decimal(params)

    case Decimal.equal?(denominator, 0) do
      false -> Decimal.div(current, denominator)
      true -> nil
    end
  end

  defp get_event_question(event_answer_params, event_questions) do
    event_question_id =
      event_answer_params
      |> Map.fetch!("event_question_id")
      |> Artemis.Helpers.to_integer()

    Enum.find(event_questions, &(&1.id == event_question_id))
  end

  defp record_event_answer(params, user) do
    id = Map.get(params, "id")
    id? = !is_nil(id)
    to_be_deleted? = Map.get(params, "delete") == "true"

    action =
      cond do
        id? && to_be_deleted? ->
          fn _params, user -> DeleteEventAnswer.call(id, user) end

        id? ->
          fn params, user -> UpdateEventAnswer.call(id, params, user) end

        true ->
          fn params, user ->
            case CreateEventAnswer.call(params, user) do
              {:ok, record} -> {:ok, Map.put(record, :id, nil)}
              error -> error
            end
          end
      end

    case action.(params, user) do
      {:ok, record} -> {:ok, EventAnswer.changeset(record, params)}
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
      {:error, _} -> {:error, EventAnswer.changeset(%EventAnswer{}, params)}
    end
  rescue
    _ in DBConnection.ConnectionError ->
      id = Map.get(params, "id")
      struct = %EventAnswer{id: id}
      changeset = EventAnswer.changeset(struct, params)

      {:error, changeset}

    error ->
      reraise error, __STACKTRACE__
  end
end
