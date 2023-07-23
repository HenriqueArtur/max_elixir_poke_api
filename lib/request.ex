defmodule MaxElixirPokeApi.Request do
  @moduledoc false

  alias MaxElixirPokeApi.{
    Cache
  }

  @type id_or_name :: String.t() | integer
  @type response :: {:ok, map} | {:error, %{reason: String.t()}}

  @url "https://pokeapi.co/api/v2/"

  @http_client Application.compile_env(:max_elixir_poke_api, :http_client)

  @doc """
  Resource List endpoint pipeline.
  """
  @spec get(String.t(), integer, integer) :: response
  def get(resource, limit, page) do
    if resource do
      case Cache.exists?(:max_elixir_cache, resource) do
        {:ok, true} ->
          {:ok, value} = Cache.get(:max_elixir_cache, resource)
          value
        {:ok, false} ->
          resource
          |> make_url(limit, page)
          |> get_url
          |> save_cache(resource)
      end
    else
      {:error, %{reason: "resource not valid."}}
    end
  end

  @doc """
  Single Resource endpoint pipeline.
  """
  @spec get(String.t(), id_or_name) :: response
  def get(resource, id_or_name) do
    key = "#{resource}-#{id_or_name}"
    case Cache.exists?(:max_elixir_cache, key) do
      {:ok, true} ->
        {:ok, value} = Cache.get(:max_elixir_cache, key)
        value
      {:ok, false} ->
        resource
        |> make_url(id_or_name)
        |> get_url
        |> save_cache(key)
    end
  end

  @doc false
  defp make_url(resource, id_or_name), do: "#{@url}#{resource}/#{to_string(id_or_name)}"
  defp make_url(resource, limit, page), do: "#{@url}#{resource}?limit=#{limit}&offset=#{limit * page}"

  @doc false
  defp get_url(url), do: @http_client.get(url)

  @doc false
  defp save_cache(resource, key) do
    { _status, data }= Cache.put(:max_elixir_cache, key, resource)
    data
  end
end
