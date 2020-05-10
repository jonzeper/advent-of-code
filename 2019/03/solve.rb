class Line
  def initialize(first, last)
    @first = first
    @last = last
  end
end

class Wire
  def initialize
    pos_x = 0
    pos_y = 0
    h_lines = []
    v_lines = []
  end

  def add_line(orientation, first, last)
    if orientation == :vertical
      v_lines << Line.new(first, last)
    else
      h_lines << Line.new(first, last)
    end
  end

  def add_point(dir, len)
    case dir
    when 'U' then pos_y += len
    when 'D' then pos_y -= len
    when 'L' then pos_x -= len
    when 'R' then pos_x += len
    end
  end

  def add(instruction)
    dir = instruction[0]
    len = instruction[1..99].to_i
end

class Solver
  def initialize
    @closest_pt = [0, 0]
    @closest_dist = -1
    @instructions = File.new('input.txt').map(&:strip).map {|i| i.split(',')}
    wire_1 = Wire.new
    @instructions[0].each do |inst|
      wire_1.add(inst)
    end
    @instructions[1].each do |inst|
      intersections = wire_2.add_and_check(inst, wire_1)
      intersections.each do |intersection|
        # If dist < @closest_dist, update @closest_dist and @closest_pt
      end
    end
  end

  def solve
  end
end

solver = Solver.new
solver.solve
