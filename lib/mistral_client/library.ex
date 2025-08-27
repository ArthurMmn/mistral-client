defmodule MistralClient.Library do
  @moduledoc """
  Library management API operations for MistralClient.

  Provides functions to manage libraries through REST API endpoints:
  - List all libraries
  - Create a new library
  - Get a specific library by ID
  - Update an existing library
  """

  alias MistralClient.Client
  alias MistralClient.Config

  @libraries_base_url "/v1/libraries"

  @doc """
  Get the base URL for libraries endpoint
  """
  def libraries_url(), do: @libraries_base_url

  @doc """
  Get the base URL for individual library endpoint
  """
  def library_url(id), do: "#{@libraries_base_url}/#{id}"

  @doc """
  Fetch all libraries.

  ## Parameters
  - `params` - Optional query parameters
  - `config` - Optional configuration override

  ## Examples
      iex> MistralClient.Library.list()
      {:ok, %{data: [%{"id" => "1", "name" => "My Library", ...}]}}

  ## Returns
  - `{:ok, response}` on success
  - `{:error, reason}` on failure
  """
  def list(params \\ [], config \\ %Config{}) do
    libraries_url()
    |> Client.api_get(params, config)
  end

  @doc """
  Create a new library.

  ## Parameters
  - `params` - Library data (name, description, etc.)
  - `config` - Optional configuration override

  ## Examples
      iex> MistralClient.Library.create(name: "New Library", description: "A test library")
      {:ok, %{"id" => "123", "name" => "New Library", "description" => "A test library", ...}}

  ## Returns
  - `{:ok, library}` on successful creation
  - `{:error, reason}` on failure
  """
  def create(params, config \\ %Config{}) do
    libraries_url()
    |> Client.api_post(params, config)
  end

  @doc """
  Fetch a specific library by ID.

  ## Parameters
  - `id` - The library ID
  - `config` - Optional configuration override

  ## Examples
      iex> MistralClient.Library.get("123")
      {:ok, %{"id" => "123", "name" => "My Library", ...}}

  ## Returns
  - `{:ok, library}` on success
  - `{:error, reason}` on failure (including not found)
  """
  def get(id, config \\ %Config{}) do
    library_url(id)
    |> Client.api_get([], config)
  end

  @doc """
  Update an existing library by ID.

  ## Parameters
  - `id` - The library ID
  - `params` - Updated library data
  - `config` - Optional configuration override

  ## Examples
      iex> MistralClient.Library.update("123", name: "Updated Name")
      {:ok, %{"id" => "123", "name" => "Updated Name", ...}}

  ## Returns
  - `{:ok, library}` on successful update
  - `{:error, reason}` on failure
  """
  def update(id, params, config \\ %Config{}) do
    library_url(id)
    |> Client.api_put(params, config)
  end

  @doc """
  Delete a library by ID.

  ## Parameters
  - `id` - The library ID
  - `config` - Optional configuration override

  ## Examples
      iex> MistralClient.Library.delete("123")
      {:ok, %{"message" => "Library deleted successfully"}}

  ## Returns
  - `{:ok, response}` on successful deletion
  - `{:error, reason}` on failure
  """
  def delete(id, config \\ %Config{}) do
    library_url(id)
    |> Client.api_delete(config)
  end
end
