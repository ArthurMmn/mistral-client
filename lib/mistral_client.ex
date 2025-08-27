defmodule MistralClient do
  @moduledoc """
  Provides API wrappers for Mistral API
  See https://docs.mistral.ai/api for further info on REST endpoints
  """

  use Application

  alias MistralClient.Agent
  alias MistralClient.Chat
  alias MistralClient.Config
  alias MistralClient.Conversation
  alias MistralClient.Document
  alias MistralClient.Embeddings
  alias MistralClient.Library
  alias MistralClient.Models

  def start(_type, _args) do
    children = [Config]
    opts = [strategy: :one_for_one, name: MistralClient.Supervisor]

    Supervisor.start_link(children, opts)
  end

  @doc """
  Retrieve the list of available models
  ## Example request
  ```elixir
  MistralClient.models()
  ```

  ## Example response
  ```elixir
  {:ok,
    %{
      data: [
        %{
          "created" => 1702997889,
          "id" => "mistral-medium-latest",
          "object" => "model",
          "owned_by" => "mistralai",
          "parent" => nil,
          "permission" => [
            %{
              "allow_create_engine" => false,
              "allow_fine_tuning" => false,
              "allow_logprobs" => false,
              ....
             }
          ],
          "root" => nil
        }
      ]
    }
  }
  ```

  See: https://docs.mistral.ai/api#operation/listModels
  """

  def models(), do: Models.fetch()

  @doc """
  Creates a completion for the chat message

  ## Example request
  ```elixir
  MistralClient.chat(
    "model": "open-mistral-7b",
    "messages": [
      %{
        "role": "user",
        "content": "What is the best French cheese?"
      }
    ]
  )
  ```

  ## Example response
  ```elixir
  {:ok,
    %{
      choices: [
        %{
          "finish_reason" => "stop",
   "index" => 0,
   "message" => %{
            "content" => "It's subjective to determine the 'best' French cheese as it depends on personal preferences. Here are some popular and highly regarded French cheeses in various categories:\n\n1. Soft and Bloomy Rind: Brie de Meaux or Brie de Melun, Camembert de Normandie\n2. Hard and Cooked: Comté, Gruyère\n3. Hard and Uncooked: Cheddar-like: Comté, Beaufort, Appenzeller-style: Vacherin Fribourgeois, Alpine-style: Reblochon\n4. Blue Cheese: Roquefort, Fourme d'Ambert\n5. Goat Cheese: Chavignol, Crottin de Chavignol, Sainte-Maure de Touraine\n\nHowever, I would recommend trying a variety of French cheeses to discover your favorite. It's an enjoyable and delicious experience!",
            "role" => "assistant"
          }
        }
     ],
     created: 1702997889,
     id: "cmpl-83f575cf654b4a83b99d342f644db292",
     model: "open-mistral-7b",
     object: "chat.completion",
     usage: %{
       "completion_tokens" => 204,
       "prompt_tokens" => 15,
       "total_tokens" => 219
     }
   }
  }
  ```

  N.B. to use "stream" mode you must be set http_options as below when you want to treat the chat completion as a stream. You may also pass in the api_key in the same way, or define in the config.exs of your elixir project.

  ## Example request (stream)
  ```elixir
  MistralClient.chat(
    [
      model: "open-mistral-7b",
      messages: [
        %{role: "user", content: "What is the best French cheese?"}
      ],
      stream: true
    ],
    MistralClient.config(http_options: %{stream_to: self(), async: :once})
  )
  |> Stream.each(fn res ->
    IO.inspect(res)
  end)
  |> Stream.run()
  ```

  ## Example response (stream)
  ```elixir
  %{
    "choices" => [
      %{"delta" => %{"role" => "assistant"}, "finish_reason" => nil, "index" => 0}
    ],
    "id" => "cmpl-9d2c56da16394e009cafbbde9cb5d725",
    "model" => "open-mistral-7b"
  }
  %{
    "choices" => [
      %{
        "delta" => %{
          "content" => "It's subjective to determine the 'best'",
          "role" => nil
        },
        "finish_reason" => nil,
        "index" => 0
      }
    ],
    "created" => 1702999980,
    "id" => "cmpl-9d2c56da16394e009cafbbde9cb5d725",
    "model" => "open-mistral-7b",
    "object" => "chat.completion.chunk"
  }
  %{
    "choices" => [
      %{
        "delta" => %{
          "content" => " French cheese as it largely depends on personal preferences. Here are a",
          "role" => nil
        },
        "finish_reason" => nil,
        "index" => 0
      }
    ],
    "created" => 1702999980,
    "id" => "cmpl-9d2c56da16394e009cafbbde9cb5d725",
    "model" => "open-mistral-7b",
    "object" => "chat.completion.chunk"
  }
  ```

  See: https://docs.mistral.ai/api#operation/createChatCompletion for the complete list of parameters you can pass to the chat function
  """
  def chat(params, config \\ Config.config(%{})) do
    Chat.fetch(params, config)
  end

  def agent_completion(params, config \\ Config.config(%{})) do
    Agent.completion(params, config)
  end

  @doc """
  Creates an embedding vector representing the input text.

  ## Example request
  ```elixir
  MistralClient.embeddings(
    model: "mistral-embed",
    input: [
      "Embed this sentence.",
      "As well as this one."
    ]
  )
  ```

  ## Example response
  ```elixir
  {:ok,
   %{
    data: [
     %{
       "embedding" => [-0.0165863037109375, 0.07012939453125, 0.031494140625,
        0.013092041015625, 0.020416259765625, 0.00977325439453125,
        0.0256195068359375, 0.0021114349365234375, -0.00867462158203125,
        -0.00876617431640625, -0.039520263671875, 0.058441162109375,
        -0.025390625, 0.00748443603515625, -0.0290679931640625,
        0.040557861328125, 0.05474853515625, 0.0258636474609375,
        0.031890869140625, 0.0230255126953125, -0.056427001953125,
        -0.01617431640625, -0.061248779296875, 0.012115478515625,
        -0.045745849609375, -0.0269622802734375, -0.0079498291015625,
        -0.03778076171875, -0.040008544921875, 8.23974609375e-4,
        0.0242767333984375, -0.02996826171875, 0.0305023193359375,
        -0.0022830963134765625, -0.012237548828125, -0.036163330078125,
        -0.033172607421875, -0.044891357421875, 0.01326751708984375,
        0.0021228790283203125, 0.00978851318359375, -2.1147727966308594e-4,
        -0.0305633544921875, -0.0230865478515625, -0.024932861328125, ...],
       "index" => 0,
       "object" => "embedding"
     },
     %{
       "embedding" => [-0.0234222412109375, 0.039337158203125,
        0.052398681640625, -0.0183868408203125, 0.03399658203125,
        0.003879547119140625, 0.024688720703125, -5.402565002441406e-4,
        -0.0119171142578125, -0.006988525390625, -0.0136260986328125,
        0.041839599609375, -0.0274810791015625, -0.015411376953125,
        -0.041412353515625, 0.0305328369140625, 0.006023406982421875,
        0.001140594482421875, -0.007167816162109375, 0.01085662841796875,
        -0.03668212890625, -0.033111572265625, -0.044586181640625,
        0.020538330078125, -0.0423583984375, -0.03131103515625,
        -0.0119781494140625, -0.048736572265625, -0.0850830078125,
        0.0203857421875, -0.0023899078369140625, -0.0249176025390625,
        0.019500732421875, 0.007068634033203125, 0.0301055908203125,
        -0.041534423828125, -0.0255584716796875, -0.0246429443359375,
        0.022674560546875, -2.760887145996094e-4, -0.015045166015625,
        -0.01788330078125, 0.0146484375, -0.005573272705078125, ...],
       "index" => 1,
       "object" => "embedding"
     }
    ],
    id: "embd-7d921a4410e249b9960195ab6705b255",
    model: "mistral-embed",
    object: "list",
    usage: %{
      "completion_tokens" => 0,
      "prompt_tokens" => 15,
      "total_tokens" => 15
    }
  }}
  ```
  See: https://docs.mistral.ai/api#operation/createEmbedding
  """
  def embeddings(params, config \\ Config.config(%{})) do
    Embeddings.fetch(params, config)
  end

  @doc """
  List all conversations.

  ## Example request
  ```elixir
  MistralClient.conversations()
  ```

  ## Example response
  ```elixir
  {:ok,
    %{
      data: [
        %{
          "id" => "conv123",
          "messages" => [
            %{"role" => "user", "content" => "Hello!"},
            %{"role" => "assistant", "content" => "Hi there!"}
          ],
          "created_at" => "2023-12-01T10:00:00Z",
          "updated_at" => "2023-12-01T10:30:00Z"
        }
      ]
    }
  }
  ```
  """
  def conversations(params \\ [], config \\ Config.config(%{})) do
    Conversation.list(params, config)
  end

  @doc """
  Create or update a conversation.

  ## Example request (create new)
  ```elixir
  MistralClient.conversation(nil,
    messages: [
      %{role: "user", content: "Hello!"}
    ]
  )
  ```

  ## Example request (update existing)
  ```elixir
  MistralClient.conversation("conv123",
    messages: [
      %{role: "user", content: "Hello!"},
      %{role: "assistant", content: "Hi there!"},
      %{role: "user", content: "How are you?"}
    ]
  )
  ```

  ## Example response
  ```elixir
  {:ok,
    %{
      "id" => "conv123",
      "messages" => [
        %{"role" => "user", "content" => "Hello!"},
        %{"role" => "assistant", "content" => "Hi there!"}
      ],
      "created_at" => "2023-12-01T10:00:00Z",
      "updated_at" => "2023-12-01T10:30:00Z"
    }
  }
  ```
  """
  def conversation(conversation_id, params, config \\ Config.config(%{})) do
    Conversation.create_or_continue(conversation_id, params, config)
  end

  @doc """
  Get the history of a conversation.

  ## Example request
  ```elixir
  MistralClient.conversation_history("conv123")
  ```

  ## Example response
  ```elixir
  {:ok,
    %{
      "messages" => [
        %{"role" => "user", "content" => "Hello!", "timestamp" => "2023-12-01T10:00:00Z"},
        %{"role" => "assistant", "content" => "Hi there!", "timestamp" => "2023-12-01T10:01:00Z"},
        %{"role" => "user", "content" => "How are you?", "timestamp" => "2023-12-01T10:02:00Z"}
      ],
      "total" => 3,
      "conversation_id" => "conv123"
    }
  }
  ```
  """
  def conversation_history(conversation_id, params \\ [], config \\ Config.config(%{})) do
    Conversation.history(conversation_id, params, config)
  end

  @doc """
  Create a new conversation (convenience function).

  ## Example request
  ```elixir
  MistralClient.create_conversation(
    messages: [
      %{role: "user", content: "Start a new conversation"}
    ]
  )
  ```

  ## Example response
  ```elixir
  {:ok,
    %{
      "id" => "conv456",
      "messages" => [
        %{"role" => "user", "content" => "Start a new conversation"}
      ],
      "created_at" => "2023-12-01T10:00:00Z",
      "updated_at" => "2023-12-01T10:00:00Z"
    }
  }
  ```
  """
  def create_conversation(params, config \\ Config.config(%{})) do
    Conversation.create_or_continue(nil, params, config)
  end

  @doc """
  Update an existing conversation (convenience function).

  ## Example request
  ```elixir
  MistralClient.update_conversation("conv123",
    messages: [
      %{role: "user", content: "Updated message"}
    ]
  )
  ```

  ## Example response
  ```elixir
  {:ok,
    %{
      "id" => "conv123",
      "messages" => [
        %{"role" => "user", "content" => "Updated message"}
      ],
      "created_at" => "2023-12-01T10:00:00Z",
      "updated_at" => "2023-12-01T10:35:00Z"
    }
  }
  ```
  """
  def update_conversation(conversation_id, params, config \\ Config.config(%{})) do
    Conversation.create_or_continue(conversation_id, params, config)
  end

  @doc """
  Generates the config settings from the given params, using the defaults defined in the application's config.exs if not passed in params.

  ## Example request
  ```elixir
  MistralClient.config(
    api_key: "YOUR_MISTRAL_KEY",
    http_options: %{
      stream_to: self(),
      async: :once
    }
  )
  ```
  """
  def config(params) do
    opts =
      case params do
        params_list when is_list(params_list) ->
          Enum.into(params_list, %{})

        _ ->
          params
      end

    Config.config(opts)
  end

  @doc """
  List all libraries.

  ## Example request
  ```elixir
  MistralClient.libraries()
  ```

  ## Example response
  ```elixir
  {:ok,
    %{
      data: [
        %{
          "id" => "1",
          "name" => "My Library",
          "description" => "A sample library",
          "created_at" => "2023-12-01T10:00:00Z",
          "updated_at" => "2023-12-01T10:00:00Z"
        }
      ]
    }
  }
  ```
  """
  def libraries(params \\ [], config \\ Config.config(%{})) do
    Library.list(params, config)
  end

  @doc """
  Create a new library.

  ## Example request
  ```elixir
  MistralClient.create_library(
    name: "New Library",
    description: "A new library for testing"
  )
  ```

  ## Example response
  ```elixir
  {:ok,
    %{
      "id" => "123",
      "name" => "New Library",
      "description" => "A new library for testing",
      "created_at" => "2023-12-01T10:00:00Z",
      "updated_at" => "2023-12-01T10:00:00Z"
    }
  }
  ```
  """
  def create_library(params, config \\ Config.config(%{})) do
    Library.create(params, config)
  end

  @doc """
  Get a specific library by ID.

  ## Example request
  ```elixir
  MistralClient.library("123")
  ```

  ## Example response
  ```elixir
  {:ok,
    %{
      "id" => "123",
      "name" => "My Library",
      "description" => "A sample library",
      "created_at" => "2023-12-01T10:00:00Z",
      "updated_at" => "2023-12-01T10:00:00Z"
    }
  }
  ```
  """
  def library(id, config \\ Config.config(%{})) do
    Library.get(id, config)
  end

  @doc """
  Update an existing library by ID.

  ## Example request
  ```elixir
  MistralClient.update_library("123", name: "Updated Name")
  ```

  ## Example response
  ```elixir
  {:ok,
    %{
      "id" => "123",
      "name" => "Updated Name",
      "description" => "A sample library",
      "created_at" => "2023-12-01T10:00:00Z",
      "updated_at" => "2023-12-01T10:30:00Z"
    }
  }
  ```
  """
  def update_library(id, params, config \\ Config.config(%{})) do
    Library.update(id, params, config)
  end

  @doc """
  Delete a library by ID.

  ## Example request
  ```elixir
  MistralClient.delete_library("123")
  ```

  ## Example response
  ```elixir
  {:ok, %{"message" => "Library deleted successfully"}}
  ```
  """
  def delete_library(id, config \\ Config.config(%{})) do
    Library.delete(id, config)
  end

  @doc """
  List all documents in a library.

  ## Example request
  ```elixir
  MistralClient.documents("lib123")
  ```

  ## Example response
  ```elixir
  {:ok,
    %{
      data: [
        %{
          "id" => "doc1",
          "name" => "My Document",
          "library_id" => "lib123",
          "created_at" => "2023-12-01T10:00:00Z",
          "updated_at" => "2023-12-01T10:00:00Z"
        }
      ]
    }
  }
  ```
  """
  def documents(library_id, params \\ [], config \\ Config.config(%{})) do
    Document.list(library_id, params, config)
  end

  def document(library_id, document_id, params \\ [], config \\ Config.config(%{})) do
    Document.get(library_id, document_id, params, config)
  end

  @doc """
  Create a new document in a library by uploading a file.

  ## Example request
  ```elixir
  MistralClient.create_document("lib123", "/path/to/document.pdf")
  ```

  ## Example request with additional parameters
  ```elixir
  MistralClient.create_document("lib123", "/path/to/document.pdf", [metadata: "custom"])
  ```

  ## Example response
  ```elixir
  {:ok,
    %{
      "id" => "doc456",
      "name" => "document.pdf",
      "library_id" => "lib123",
      "created_at" => "2023-12-01T10:00:00Z",
      "updated_at" => "2023-12-01T10:00:00Z"
    }
  }
  ```
  """
  def create_document(library_id, file_path, params \\ [], config \\ Config.config(%{})) do
    Document.create(library_id, file_path, params, config)
  end

  @doc """
  Create a new document in a library with a custom filename.

  This function is specifically designed to work with Phoenix file uploads,
  preserving the original filename from the upload.

  ## Example request in Phoenix controller
  ```elixir
  def create_document(conn, %{"library_id" => library_id, "file" => upload}) do
    case MistralClient.create_document_with_filename(library_id, upload.path, upload.filename) do
      {:ok, document} ->
        json(conn, document)
      {:error, reason} ->
        conn |> put_status(400) |> json(%{error: reason})
    end
  end
  ```

  ## Example response
  ```elixir
  {:ok,
    %{
      "id" => "doc456",
      "name" => "original_document.pdf",
      "library_id" => "lib123",
      "created_at" => "2023-12-01T10:00:00Z",
      "updated_at" => "2023-12-01T10:00:00Z"
    }
  }
  ```
  """
  def create_document_with_filename(
        library_id,
        file_path,
        filename,
        params \\ [],
        config \\ Config.config(%{})
      ) do
    Document.create_with_filename(library_id, file_path, filename, params, config)
  end

  @doc """
  Delete a document from a library.

  ## Example request
  ```elixir
  MistralClient.delete_document("lib123", "doc456")
  ```

  ## Example response
  ```elixir
  {:ok, %{"message" => "Document deleted successfully"}}
  ```
  """
  def delete_document(library_id, document_id, config \\ Config.config(%{})) do
    Document.delete(library_id, document_id, config)
  end

  @doc """
  Get the text content of a specific document.

  ## Example request
  ```elixir
  MistralClient.document_text_content("lib123", "doc456")
  ```

  ## Example response
  ```elixir
  {:ok,
    %{
      "content" => "This is the document content...",
      "format" => "text/plain"
    }
  }
  ```
  """
  def document_text_content(library_id, document_id, config \\ Config.config(%{})) do
    Document.text_content(library_id, document_id, config)
  end

  @doc """
  List all agents.

  ## Example request
  ```elixir
  MistralClient.agents()
  ```

  ## Example response
  ```elixir
  {:ok,
    [
      %{
        "id" => "agent123",
        "name" => "My Agent",
        "description" => "A helpful agent",
        "object" => "agent",
        "model" => "mistral-large-latest",
        "instructions" => "You are a helpful assistant",
        "tools" => [],
        "completion_args" => %{
          "temperature" => 0.7,
          "max_tokens" => 1000
        },
        "created_at" => "2023-12-01T10:00:00Z",
        "updated_at" => "2023-12-01T10:00:00Z",
        "version" => 1
      }
    ]
  }
  ```
  """
  def agents(params \\ [], config \\ Config.config(%{})) do
    Agent.list(params, config)
  end

  @doc """
  Get a specific agent by ID.

  ## Example request
  ```elixir
  MistralClient.agent("agent123")
  ```

  ## Example response
  ```elixir
  {:ok,
    %{
      "id" => "agent123",
      "name" => "My Agent",
      "description" => "A helpful agent",
      "object" => "agent",
      "model" => "mistral-large-latest",
      "instructions" => "You are a helpful assistant",
      "tools" => [],
      "completion_args" => %{
        "temperature" => 0.7,
        "max_tokens" => 1000
      },
      "created_at" => "2023-12-01T10:00:00Z",
      "updated_at" => "2023-12-01T10:00:00Z",
      "version" => 1
    }
  }
  ```
  """
  def agent(id, config \\ Config.config(%{})) do
    Agent.get(id, config)
  end

  @doc """
  Update an existing agent by ID.

  ## Example request
  ```elixir
  MistralClient.update_agent("agent123",
    name: "Updated Agent Name",
    instructions: "You are an updated helpful assistant"
  )
  ```

  ## Example response
  ```elixir
  {:ok,
    %{
      "id" => "agent123",
      "name" => "Updated Agent Name",
      "description" => "A helpful agent",
      "object" => "agent",
      "model" => "mistral-large-latest",
      "instructions" => "You are an updated helpful assistant",
      "tools" => [],
      "completion_args" => %{
        "temperature" => 0.7,
        "max_tokens" => 1000
      },
      "created_at" => "2023-12-01T10:00:00Z",
      "updated_at" => "2023-12-01T10:30:00Z",
      "version" => 2
    }
  }
  ```
  """
  def update_agent(id, params, config \\ Config.config(%{})) do
    Agent.update(id, params, config)
  end

  def create_agent(params, config \\ Config.config(%{})) do
    Agent.create(params, config)
  end
end
