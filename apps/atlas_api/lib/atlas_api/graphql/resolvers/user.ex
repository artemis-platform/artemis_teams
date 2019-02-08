defmodule AtlasApi.GraphQL.Resolver.User do
  import AtlasApi.UserAccess

  alias Atlas.CreateUser
  alias Atlas.DeleteUser
  alias Atlas.GetUser
  alias Atlas.ListUsers
  alias Atlas.UpdateUser

  # Queries

  def list(_params, context) do
    require_permission context, "users:list", fn () ->
      {:ok, ListUsers.call()}
    end
  end

  def get(%{id: id}, context) do
    require_permission context, "users:show", fn () ->
      {:ok, GetUser.call(id)}
    end
  end

  # Mutations

  def create(%{user: params}, context) do
    require_permission context, "users:create", fn () ->
      CreateUser.call(params, get_user(context))
    end
  end

  def update(%{id: id, user: params}, context) do
    require_permission context, "users:update", fn () ->
      UpdateUser.call(id, params, get_user(context))
    end
  end

  def delete(%{id: id}, context) do
    require_permission context, "users:delete", fn () ->
      DeleteUser.call(id, get_user(context))
    end
  end
end
