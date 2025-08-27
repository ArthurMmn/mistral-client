defmodule MistralClient.Conversation do
  @moduledoc """
  Conversation management API operations for MistralClient.

  Provides functions to manage conversations through REST API endpoints:
  - Create or update conversations
  - Get conversation history
  """

  alias MistralClient.Client
  alias MistralClient.Config

  @base_url "/v1/conversations"
  @update_url "/v1/conversations/%{id}"
  @history_url "/v1/conversations/%{id}/history"

  @doc """
  Get the base URL for conversations endpoint
  """
  def conversations_url(), do: @base_url

  @doc """
  Get the URL for a specific conversation
  """
  def conversation_url(nil), do: @base_url
  def conversation_url(conversation_id), do: String.replace(@update_url, "%{id}", conversation_id)

  @doc """
  Get the URL for conversation history
  """
  def conversation_history_url(conversation_id),
    do: String.replace(@history_url, "%{id}", "#{conversation_id}")

  @doc """
  List all conversations.

  ## Parameters
  - `params` - Optional query parameters
  - `config` - Optional configuration override

  ## Examples
      iex> MistralClient.Conversation.list()
      {:ok, %{data: [%{"id" => "conv1", "messages" => [...], ...}]}}

  ## Returns
  - `{:ok, conversations}` on success
  - `{:error, reason}` on failure
  """
  def list(params \\ [], config \\ %Config{}) do
    conversations_url()
    |> Client.api_get(params, config)
  end

  @doc """
  Create or update a conversation.

  ## Parameters
  - `conversation_id` - The conversation ID (nil for new conversation)
  - `params` - Conversation parameters
  - `config` - Optional configuration override

  ## Examples
      # Create new conversation
      iex> MistralClient.Conversation.create_or_continue(nil, messages: [...])
      {:ok, %{"id" => "conv123", "messages" => [...], ...}}

      # Update existing conversation
      iex> MistralClient.Conversation.create_or_continue("conv123", messages: [...])
      {:ok, %{"id" => "conv123", "messages" => [...], ...}}

  ## Returns
  - `{:ok, conversation}` on success
  - `{:error, reason}` on failure
  """
  def create_or_continue(conversation_id, params, config \\ %Config{}) do
    conversation_id
    |> conversation_url()
    |> Client.api_post(params, config)
  end

  @doc """
  Get the history of a conversation.

  ## Parameters
  - `conversation_id` - The conversation ID
  - `params` - Optional query parameters
  - `config` - Optional configuration override

  ## Examples
      iex> MistralClient.Conversation.history("conv123")
      {:ok, %{"messages" => [...], "total" => 10, ...}}

  ## Returns
  - `{:ok, history}` on success
  - `{:error, reason}` on failure
  """
  def history(conversation_id, params \\ [], config \\ %Config{}) do
    conversation_id
    |> conversation_history_url()
    |> Client.api_get(params, config)
  end
end
