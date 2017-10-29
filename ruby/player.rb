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
    str = ''
    pos_y = @y_glass.map do |column|
      y = column.index('    ')
      y ? y : MAX_Y
    end
    p pos_y
    x = pos_y.each_with_index.min[1]
    print 'min='
    p x
    if x < @x
      str << "left=#{@x - x}, "
    elsif x > @x
      str << "right=#{x - @x}, "
    end
    str << 'drop'
    puts "I: y=#{pos_y.min} x=#{x}, str=\"#{str}\""
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
