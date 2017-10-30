class Player

  MAX_X = 10
  MAX_Y = 20
  SIZE = MAX_X * MAX_Y

  # initialize player
  def initialize
    # @x_glass -- straight (vertical standing) glass
    @x_glass = Array.new(MAX_Y) { '' }
    # @y_glass -- transposed (horizontal) glass
    @y_glass = Array.new(MAX_X) { ' ' * MAX_Y }
    @glass = Hash.new([0, 0])
    -1.upto(MAX_X) do |x|
      @glass[[-1, x]] = :bottom
      @glass[[MAX_Y, x]] = :wall
    end
    -1.upto(MAX_Y) do |y|
      @glass[[y, -1]] = :wall
      @glass[[y, MAX_X]] = :wall
    end
  end

  # process data for each event from tetris-server
  def process_data(data)
    @figure = data[/figure=.+?/][7, 1].to_sym
    @x = data[/x=\d+/][2, 2].to_i
    @y = data[/y=\d+/][2, 2].to_i
    @next = data[/next=\w{4}/][5, 4]
    glass_str = data[/glass=.{#{SIZE}}/][6, 6 + SIZE]
    MAX_Y.times { |y| @x_glass[y] = glass_str[y * MAX_X, MAX_X] }
    MAX_X.times do |x|
      MAX_Y.times do |y|
        cell = @x_glass[y][x]
        @y_glass[x][y] = cell
        case cell
        when ' ' then @glass[[y, x]] = :space
        when '*' then @glass[[y, x]] = :block
        end
      end
    end
    MAX_Y.times { |y| p @x_glass[MAX_Y - 1 - y] }
    #MAX_X.times { |x| p @y_glass[x] }
  end

  # This method returns string like left=0, right=0, rotate=0, drop'
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

  #
  # Find lowest level for block with given width
  #
  def find_lowest(width)
    y = MAX_Y - 1
    x = 0
    # process every column and find first free cell
    y_cur = @y_glass.map do |column|
      i = column.reverse.index('*')
      i ? MAX_Y - i : 0
    end
    # find continuous line with 'width' number of free cells
    (MAX_X - width + 1).times do |x_cur|
      if y_cur[x_cur..x_cur + width - 1].uniq.size == 1 && y_cur[x_cur] < y
        y = y_cur[x_cur]
        x = x_cur
      end
    end
    # find not continuous line with 'width' number of free cells
    (MAX_X - width + 1).times do |x_cur|
      y_max = y_cur[x_cur..x_cur + width - 1].max
      if y_max < y - 2
        y = y_max
        x = x_cur
      end
    end
    [x, y]
  end

  #
  # Forming result string
  #
  def result_string(x, rotate = 0)
    str = ''
    if x < @x
      str << "left=#{@x - x}, "
    elsif x > @x
      str << "right=#{x - @x}, "
    end
    str << "rotate=#{rotate}, " if rotate > 0
    str << 'drop'
  end

  # Process O block
  #
  #   **
  #   **
  #
  def step_o
    # x, y = find_lowest(2)
    # result_string(x)
    result_string(score_o)
  end

  # Process I block
  #
  #   *
  #   *
  #   *
  #   *
  #
  def step_i

    # Process vertical I block
    x_vert, y_vert = find_lowest(1)

    # Process horizontal I block
    x_horiz, y_horiz = find_lowest(4)

    if y_vert < y_horiz
      result_string(x_vert)
    else
      result_string(x_horiz + 2, 1)
    end
  end

  # Process L block
  #
  #   *
  #   *
  #   **
  #
  def step_l

    # Process rotate = 0
    x_1, y_1 = find_lowest(2)

    # Process rotate = 3
    x_2, y_2 = find_lowest(3)

    if y_1 < y_2
      result_string(x_1)
    else
      result_string(x_2 + 1, 3)
    end
  end

  # Process J block
  #
  #     *
  #     *
  #    **
  #
  def step_j

    # Process rotate = 0
    x_1, y_1 = find_lowest(2)

    # Process rotate = 1
    x_2, y_2 = find_lowest(3)

    if y_1 < y_2
      result_string(x_1 + 1)
    else
      result_string(x_2 + 1, 1)
    end
  end

  # Process S block
  #
  #    **
  #   **
  #
  def step_s
    x, y = find_lowest(2)
    result_string(x + 1)
  end

  # Process Z block
  #
  #    **
  #     **
  #
  def step_z
    x, y = find_lowest(2)
    result_string(x)
  end

  # Process T block
  #
  #    *
  #   ***
  #
  def step_t
    x, y = find_lowest(3)
    result_string(x + 1)
  end

  def drop_score
    case @figure
      when :O then score_o
      when :I then score_i
      when :L then score_l
      when :J then score_j
      when :S then score_s
      when :Z then score_z
      when :T then score_t
    end
  end

  def score(cell)
    case cell
    when :wall then 1
    when :block then 2
    when :bottom then 2
    else 0
    end
  end

  def score_o
    scr = [0] * (MAX_X - 1)
    y_cur = @y_glass.map do |column|
      i = column.reverse.index('*')
      i ? MAX_Y - i : 0
    end

    (MAX_X - 1).times do |x|
      y = y_cur[x..x + 1].max
      scr[x] += score(@glass[[y + 1, x - 1]])
      scr[x] += score(@glass[[y, x - 1]])
      scr[x] += score(@glass[[y - 1, x - 1]])
      scr[x] += score(@glass[[y - 1, x]])
      scr[x] += score(@glass[[y - 1, x + 1]])
      scr[x] += score(@glass[[y - 1, x + 2]])
      scr[x] += score(@glass[[y, x + 2]])
      scr[x] += score(@glass[[y + 1, x + 2]])
    end
    scr.each_with_index.max[1]
  end

end
