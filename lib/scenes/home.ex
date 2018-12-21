defmodule ChaosGame.Scene.Home do
  @type coordinate :: {integer, integer}
  use Scenic.Scene

  alias Scenic.Graph

  import Scenic.Primitives
  # import Scenic.Components

  @n_points 3
  @lerp_value 0.5

  # ============================================================================
  # utility functions
  #
  defp deg2rad(degrees) do
    degrees * (:math.pi() / 180)
  end

  @doc """
  Implementation of linear interpolation between two points

  Takes two coordinates to lerp and the percentage to travel
  from the first coordinate to the second one.
  """
  @spec lerp(coordinate, coordinate, integer) :: coordinate
  def lerp({x1, y1}, {x2, y2}, percent) do
    x = x1 + (x2 - x1) * percent || 0
    y = y1 + (y2 - y1) * percent || 0
    {x, y}
  end


  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(_, _) do
    graph =
      Graph.build(font: :roboto, font_size: 24)
      |> ellipse({300, 300}, translate: {350, 350}, stroke: {3, :white})

    deg_offset = 360 / @n_points

    {graph, _} =
      Enum.reduce(0..@n_points, {graph, 0}, fn n, {graph, current_deg} ->
        x = 350 + 300 * :math.cos(deg2rad(current_deg))
        y = 350 + 300 * :math.sin(deg2rad(current_deg))

        graph =
          graph
          |> ellipse({3, 3}, translate: {x, y}, fill: :red, id: :"point_#{n}")

        {graph, current_deg + deg_offset}
      end)

    push_graph(graph)

    initial = {Enum.random(0..700), Enum.random(0..700)}

    :erlang.send_after(1000, self(), :handle_points)
    {:ok, {initial, graph}}
  end

  # ============================================================================
  # callbacks
  #
  def handle_info(:handle_points, {last_point, graph}) do
    {new_point, graph} = Enum.reduce(0..100, {last_point, graph}, fn _, {last_point, graph} ->
      point_to_travel_to = Enum.random(1..@n_points)
      point = Enum.at(Graph.get(graph, :"point_#{point_to_travel_to}"), 0)
      coordinate = point.transforms.translate
      new_point = lerp(last_point, coordinate, @lerp_value)
      graph = graph
              |> ellipse({1, 1}, fill: :green, translate: new_point)

      {new_point, graph}
    end)
    push_graph(graph)
    :erlang.send_after(10, self(), :handle_points)
    {:noreply, {new_point, graph}}
  end
end
