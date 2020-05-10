# TODO: collisions_possible? not working, but got answer anyway

defmodule Particle do
  defstruct [:id, :pos, :vel, :acc]
end

defmodule ParticleField do
  defstruct [:particles]

  def run_sim(pf) do
    pf =
      pf
      |> eliminate_collisions()
      |> tick()

    IO.inspect particle_count(pf)

    if collisions_possible?(pf), do: run_sim(pf), else: pf
  end

  def collisions_possible?(pf) do
    !(sort_by_acc(pf.particles) === sort_by_vel(pf.particles) === sort_by_pos(pf.particles))
  end

  def sort_by_acc(particles) do
    Enum.sort_by(particles, fn(p) -> p.acc end)
  end

  def sort_by_vel(particles) do
    Enum.sort_by(particles, fn(p) -> p.vel end)
  end

  def sort_by_pos(particles) do
    Enum.sort_by(particles, fn(p) -> p.pos end)
  end

  def find_collisions(pf = %ParticleField{}), do: find_collisions(pf.particles)
  def find_collisions(particles) do
    {_, collided} =
      particles
      |> Enum.sort_by(fn(p) -> p.pos end)
      |> Enum.reduce({%Particle{pos: nil}, MapSet.new()}, fn(p, {last, collided} = _) ->
        if p.pos === last.pos do
          {p, MapSet.union(collided, MapSet.new([last.id, p.id]))}
        else
          {p, collided}
        end
      end)
    collided
  end

  def eliminate_collisions(pf = %ParticleField{}), do: %ParticleField{pf | particles: eliminate_collisions(pf.particles)}
  def eliminate_collisions(particles) do
    collided = find_collisions(particles)
    Enum.filter(particles, fn(p) ->
      !MapSet.member?(collided, p.id)
    end)
  end

  def tick(pf = %ParticleField{}), do: %ParticleField{pf | particles: tick(pf.particles)}
  def tick(particles) do
    Enum.map(particles, fn(p) ->
      {ax, ay, az} = p.acc
      {vx, vy, vz} = p.vel
      vel = {vx + ax, vy + ay, vz + az}
      {vx, vy, vz} = vel
      {px, py, pz} = p.pos
      pos = {px + vx, py + vy, pz + vz}
      %Particle{p | pos: pos, vel: vel}
    end)
  end

  def particle_count(pf) do
    length(pf.particles)
  end
end

defmodule Solver do
  def parse_particles do
    File.stream!("input")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&(Regex.named_captures(~r/p=<(?<pos>.*)>, v=<(?<vel>.*)>, a=<(?<acc>.*)>/, &1)))
    |> Enum.with_index()
    |> Enum.map(fn({%{"pos" => pos, "vel" => vel, "acc" => acc}, i}) ->
      %Particle{id: i, acc: parse_vector(acc), vel: parse_vector(vel), pos: parse_vector(pos)}
    end)
  end

  def parse_vector(vec_string) do
    vec_string
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    # |> append_vector_sum()
    |> List.to_tuple()
  end

  # def append_vector_sum(vec) do
  #   sum =
  #     vec
  #     |> Enum.map(&abs/1)
  #     |> Enum.sum()
  #   vec ++ [sum]
  # end

  def solve do
    %ParticleField{particles: parse_particles()}
    |> ParticleField.run_sim()
    |> ParticleField.particle_count()
  end
end

Solver.solve
# |> Enum.to_list
|> IO.inspect


# All collisions resolved when sort by acc == sort by vel == sort by pos
