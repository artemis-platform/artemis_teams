defmodule Artemis.DeleteManyAssociatedCommentsTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.DeleteManyAssociatedComments

  describe "call!" do
    test "raises an exception record has no comments association" do
      record = insert(:feature)

      assert_raise Artemis.Context.Error, fn ->
        DeleteManyAssociatedComments.call!(record, Mock.system_user())
      end
    end
  end

  describe "call" do
    test "returns an error if record has no comments association" do
      record = insert(:feature)

      {:error, _} = DeleteManyAssociatedComments.call(record, Mock.system_user())
    end
  end
end
