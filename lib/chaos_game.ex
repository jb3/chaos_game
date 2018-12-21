defmodule ChaosGame do
  @moduledoc """
  Implementation of the Chaos Game in Elixir.
  """

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # load the viewport configuration from config
    main_viewport_config = Application.get_env(:chaos_game, :viewport)

    # start the application with the viewport
    children = [
      supervisor(Scenic, viewports: [main_viewport_config])
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
