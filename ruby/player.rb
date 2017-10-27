class Player

  # initialize your player
  def initialize
    @glass = ''
  end

  # process data for each event from tetris-server
  def process_data(data)
    @glass = data.split('&')[3]
    @glass = @glass[6, 206]
    19.downto(0) do |i|
      p @glass[i * 10, 10]
    end
  end

  # This method should return string like left=0, right=0, rotate=0, drop'
  def make_step
    'left=4, drop'
  end
end
