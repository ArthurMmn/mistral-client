defmodule MistralClient.Document do
  @moduledoc """
  Document management API operations for MistralClient.

  Provides functions to manage documents within libraries through REST API endpoints:
  - List all documents in a library
  - Create a new document in a library
  - Delete a document from a library
  - Get the text content of a document
  """

  alias MistralClient.Client
  alias MistralClient.Config

  @documents_base_url "/v1/libraries"

  @doc """
  Get the URL for documents within a library
  """
  def documents_url(library_id), do: "#{@documents_base_url}/#{library_id}/documents"

  @doc """
  Get the URL for a specific document within a library
  """
  def document_url(library_id, document_id), do: "#{documents_url(library_id)}/#{document_id}"

  @doc """
  Get the URL for the text content of a specific document
  """
  def document_text_content_url(library_id, document_id),
    do: "#{document_url(library_id, document_id)}/text_content"

  def get(library_id, document_id, params, config \\ %Config{}) do
    document_url(library_id, document_id)
    |> Client.api_get(params, config)
  end

  @doc """
  Fetch all documents in a library.

  ## Parameters
  - `library_id` - The library ID
  - `params` - Optional query parameters
  - `config` - Optional configuration override

  ## Examples
      iex> MistralClient.Document.list("lib123")
      {:ok, %{data: [%{"id" => "doc1", "name" => "My Document", ...}]}}

  ## Returns
  - `{:ok, response}` on success
  - `{:error, reason}` on failure
  """
  def list(library_id, params \\ [], config \\ %Config{}) do
    documents_url(library_id)
    |> Client.api_get(params, config)
  end

  @doc """
  Create a new document in a library by uploading a file.

  ## Parameters
  - `library_id` - The library ID
  - `file_path` - Path to the file to upload
  - `params` - Optional additional parameters
  - `config` - Optional configuration override

  ## Examples
      iex> MistralClient.Document.create("lib123", "/path/to/document.pdf")
      {:ok, %{"id" => "doc456", "name" => "document.pdf", "library_id" => "lib123", ...}}

      iex> MistralClient.Document.create("lib123", "/path/to/document.pdf", [metadata: "custom"])
      {:ok, %{"id" => "doc456", "name" => "document.pdf", "library_id" => "lib123", ...}}

  ## Returns
  - `{:ok, document}` on successful creation
  - `{:error, reason}` on failure
  """
  def create(library_id, file_path, params \\ [], config \\ %Config{}) do
    documents_url(library_id)
    |> Client.multipart_api_post(file_path, "file", params, config)
  end

  @doc """
  Create a new document in a library using an upload struct with file path and filename.

  ## Parameters
  - `library_id` - The library ID
  - `file_path` - Path to the uploaded file
  - `filename` - Original filename to preserve
  - `params` - Optional additional parameters
  - `config` - Optional configuration override

  ## Examples
      # With Phoenix Plug.Upload
      def create_document(conn, %{"library_id" => library_id, "file" => upload}) do
        case MistralClient.Document.create_with_filename(library_id, upload.path, upload.filename) do
          {:ok, document} ->
            json(conn, document)
          {:error, reason} ->
            conn |> put_status(400) |> json(%{error: reason})
        end
      end

  ## Returns
  - `{:ok, document}` on successful creation
  - `{:error, reason}` on failure
  """
  def create_with_filename(library_id, file_path, filename, params \\ [], config \\ %Config{}) do
    documents_url(library_id)
    |> Client.multipart_api_post_with_filename(
      file_path,
      "file",
      filename,
      params,
      config
    )
  end

  @doc """
  Delete a document from a library.

  ## Parameters
  - `library_id` - The library ID
  - `document_id` - The document ID
  - `config` - Optional configuration override

  ## Examples
      iex> MistralClient.Document.delete("lib123", "doc456")
      {:ok, %{"message" => "Document deleted successfully"}}

  ## Returns
  - `{:ok, response}` on successful deletion
  - `{:error, reason}` on failure
  """
  def delete(library_id, document_id, config \\ %Config{}) do
    document_url(library_id, document_id)
    |> Client.api_delete(config)
  end

  @doc """
  Get the text content of a specific document.

  ## Parameters
  - `library_id` - The library ID
  - `document_id` - The document ID
  - `config` - Optional configuration override

  ## Examples
      iex> MistralClient.Document.text_content("lib123", "doc456")
      {:ok, %{"content" => "This is the document content..."}}

  ## Returns
  - `{:ok, content}` on success
  - `{:error, reason}` on failure
  """
  def text_content(library_id, document_id, config \\ %Config{}) do
    document_text_content_url(library_id, document_id)
    |> Client.api_get([], config)
  end
end
