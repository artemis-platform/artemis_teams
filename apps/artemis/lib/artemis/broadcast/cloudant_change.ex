defmodule Artemis.CloudantChange do
  @moduledoc """
  Broadcast cloudant change records
  """

  defmodule Data do
    defstruct [
      :action,
      :database,
      :document,
      :host,
      :id
    ]
  end

  def topic, do: "private:artemis:cloudant-changes"

  def broadcast(%{database: _, host: _, id: _} = data) do
    payload = struct(Data, data)

    :ok = ArtemisPubSub.broadcast(topic(), "cloudant-change", payload)

    data
  end

  def broadcast(data), do: data
end
