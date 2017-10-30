class Player

  MAX_X = 10
  MAX_Y = 20
  SIZE = MAX_X * MAX_Y

  # initialize your player
  def initialize
    @x_glass = Array.new(MAX_Y) { '' }
    @y_glass = Array.new(MAX_X) { ' ' * MAX_Y }
  end

  # process data for each event from tetris-server
  def process_data(data)
    @figure = data[/figure=.+?/][7, 1].to_sym
    @x = data[/x=\d+/][2, 2].to_i
    @y = data[/y=\d+/][2, 2].to_i
    @next = data[/next=\w{4}/][5, 4]
    glass = data[/glass=.{#{SIZE}}/][6, 6 + SIZE]
    MAX_Y.times { |y| @x_glass[y] = glass[y * MAX_X, MAX_X] }
    MAX_X.times { |x| MAX_Y.times { |y| @y_glass[x][y] = @x_glass[y][x] } }
    MAX_Y.times { |y| p @x_glass[MAX_Y - 1 - y] }
    MAX_X.times { |x| p @y_glass[x] }
  end

  # This method should return string like left=0, right=0, rotate=0, drop'
  def make_step
    case @figure
    when :O then step_o
    when :I then step_i
    when :L then step_l
    when :J then step_j
    when :S then step_s
    when :Z then step_z
    when :T then step_t
    end
  end

  private

  def step_o
    # str -- return command string
    str = ''
    # y -- minimum y position
    y = MAX_Y - 1
    # x -- x position for minimum y
    x = 0

    # find minimum level for element with width = 2 blocks
    (MAX_X - 1).times do |x_pos|
      y_pos = @y_glass[x_pos].reverse.index('*')
      y1 = y_pos ? MAX_Y - y_pos : 0
      y_pos = @y_glass[x_pos + 1].reverse.index('*')
      y2 = y_pos ? MAX_Y - y_pos : 0
      max_of_min = y1 > y2 ? y1 : y2
      if max_of_min < y
        y = max_of_min
        x = x_pos
      end
    end

    # forming command string
    if x < @x
      str << "left=#{@x - x}, "
    elsif x > @x
      str << "right=#{x - @x}, "
    end
    str << 'drop'
    puts "O: y=#{y}, x=#{x}, str=\"#{str}\""
    str
  end

  def step_i
    # str -- return command string
    str = ''
    # y_vert -- minimum y position in vertical mode
    y_vert = MAX_Y - 1
    # x_vert -- x position for minimum y
    x_vert = 0

    # find minimum level for element with width = 1 block
    MAX_X.times do |x_pos|
      y_pos = @y_glass[x_pos].reverse.index('*')
      y1 = y_pos ? MAX_Y - y_pos : 0
      if y1 < y_vert
        y_vert = y1
        x_vert = x_pos
      end
    end

    # y_horiz -- minimum y position in horizontal mode
    y_horiz = MAX_Y - 1
    # x_horiz -- x position for minimum y
    x_horiz = 0

    # find minimum level for element with width = 4 block
    (MAX_X - 3).times do |x_pos|
      y_pos = Array.new(4)
      4.times do |i|
        y_i = @y_glass[x_pos + i].reverse.index('*')
        y_pos[i] = y_i ? MAX_Y - y_i : 0
      end
      max_of_min, x_min = y_pos.each_with_index.max
      if max_of_min < y_horiz
        y_horiz = max_of_min
        x_horiz = x_min
      end
    end

    # forming command string
    if y_vert < y_horiz
      y = y_vert
      x = x_vert
    else
      y = y_horiz
      x = x_horiz
    end
    if x < @x
      str << "left=#{@x - x}, "
    elsif x > @x
      str << "right=#{x - @x}, "
    end
    str << 'rotate=1, ' if y_vert >= y_horiz
    str << 'drop'
    puts "I: y=#{y} x=#{x}, str=\"#{str}\""
    str
  end

  def step_l
    'drop'
  end

  def step_j
    'drop'
  end

  def step_s
    'drop'
  end

  def step_z
    'drop'
  end

  def step_t
    'drop'
  end
end
