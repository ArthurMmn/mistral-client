defmodule MistralClient.Agent do
  @moduledoc """
  Agent management API operations for MistralClient.

  Provides functions to manage agents through REST API endpoints:
  - List all agents
  - Update an existing agent
  """

  alias MistralClient.Client
  alias MistralClient.Config

  @agents_base_url "/v1/agents"
  @agent_base_url "/v1/agents"
  @agents_completions_url "/v1/agents/completions"

  @doc """
  Get the base URL for agents endpoint
  """
  def agents_url(), do: @agents_base_url

  @doc """
  Get the base URL for individual agent endpoint
  """
  def agent_url(id), do: "#{@agent_base_url}/#{id}"

  @doc """
  Get the base URL for agent completions endpoint
  """
  def agents_completions_url(), do: @agents_completions_url

  @doc """
  Fetch all agents.

  ## Parameters
  - `params` - Optional query parameters
  - `config` - Optional configuration override

  ## Examples
      iex> MistralClient.Agent.list()
      {:ok, [%{"id" => "agent1", "name" => "My Agent", "object" => "agent", ...}]}

  ## Returns
  - `{:ok, agents_list}` on success
  - `{:error, reason}` on failure
  """
  def list(params \\ [], config \\ %Config{}) do
    agents_url()
    |> Client.api_get(params, config)
  end

  @doc """
  Create a new agent

  ## Parameters
  - `params` - Agent data
  - `config` - Optional configuration override

  ## Examples
      iex> MistralClient.Agent.create(name: "Agent Name")
      {:ok, %{...}}

  ## Returns
  - `{:ok, agent}` on successful update
  - `{:error, reason}` on failure
  """
  def create(params, config \\ %Config{}) do
    agents_url()
    |> Client.api_post(params, config)
  end

  @doc """
  Update an existing agent by ID.

  ## Parameters
  - `id` - The agent ID
  - `params` - Updated agent data
  - `config` - Optional configuration override

  ## Examples
      iex> MistralClient.Agent.update("agent123", name: "Updated Agent Name")
      {:ok, %{"id" => "agent123", "name" => "Updated Agent Name", ...}}

  ## Returns
  - `{:ok, agent}` on successful update
  - `{:error, reason}` on failure
  """
  def update(id, params, config \\ %Config{}) do
    agent_url(id)
    |> Client.api_patch(params, config)
  end

  @doc """
  Fetch a specific agent by ID.

  ## Parameters
  - `id` - The agent ID
  - `config` - Optional configuration override

  ## Examples
      iex> MistralClient.Agent.get("agent123")
      {:ok, %{"id" => "agent123", "name" => "My Agent", "object" => "agent", ...}}

  ## Returns
  - `{:ok, agent}` on success
  - `{:error, reason}` on failure
  """
  def get(id, config \\ %Config{}) do
    agent_url(id)
    |> Client.api_get([], config)
  end

  @doc """
  Create agent completion.

  ## Parameters
  - `params` - Completion parameters
  - `config` - Optional configuration override

  ## Examples
      iex> MistralClient.Agent.completion(agent_id: "agent123", messages: [...])
      {:ok, %{"choices" => [...], ...}}

  ## Returns
  - `{:ok, completion}` on success
  - `{:error, reason}` on failure
  """
  def completion(params, config \\ %Config{}) do
    agents_completions_url()
    |> Client.api_post(params, config)
  end
end
