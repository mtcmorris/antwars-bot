# Represent a single field of the map.
class AntEngine::Square
	# Ant which sits on this square, or nil. The ant may be dead.
	attr_accessor :ant
	# Which row this square belongs to.
	attr_accessor :row
	# Which column this square belongs to.
	attr_accessor :col

	attr_accessor :water, :food, :hill, :ai, :last_seen, :destination

	def initialize water, food, hill, ant, row, col, ai
		@water, @food, @hill, @ant, @row, @col, @ai = water, food, hill, ant, row, col, ai
		@last_seen = 0
	end

	def destination?
	  @destination
  end

	# Returns true if this square is not water. Square is passable if it's not water, it doesn't contain alive ants and it doesn't contain food.
	def land?; !@water; end
	# Returns true if this square is water.
	def water?; @water; end
	# Returns true if this square contains food.
	def food?; @food; end
	# Returns owner number if this square is a hill, false if not
	def hill?; @hill; end

	def enemy_hill?; @hill && @hill != 0; end

	def my_hill?; @hill && @hill == 0; end
	# Returns true if this square has an alive ant.
	def ant?; @ant and @ant.alive?; end;

	# Returns a square neighboring this one in given direction.
	def neighbor direction
		direction=direction.to_s.upcase.to_sym # canonical: :N, :E, :S, :W

		case direction
		when :N
			row, col = @ai.normalize @row-1, @col
		when :E
			row, col = @ai.normalize @row, @col+1
		when :S
			row, col = @ai.normalize @row+1, @col
		when :W
			row, col = @ai.normalize @row, @col-1
		else
			raise 'incorrect direction'
		end

		return @ai.map[row][col]
	end

  def neighbors
    [:N, :S, :E, :W].map { |d|
      neighbor d
    }.select { |n|
      n.land?
    }

  #  a = [neighbor(:N), neighbor(:E), neighbor(:W), neighbor(:S)]
  end

  def nearby_squares(range = 10)
    result = []

    min_row = self.row - range
    max_row = self.row + range
    min_col = self.col - range
    max_col = self.col + range

    (min_row..max_row).each do |row|
      (min_col..max_col).each do |col|
        loc = @ai.normalize(row,col)
        result << @ai.map[loc[0]][loc[1]]
      end
    end

    result
  end

  def distance(square2)
    x_dist = (self.col - square2.col).abs
    x_dist = [x_dist, @ai.cols - x_dist].min
    y_dist = (self.row - square2.row).abs
    y_dist = [y_dist, @ai.rows - y_dist].min

    x_dist**2 + y_dist**2
  end

  def inspect
    "#{[@row, @col].inspect} ls #{@last_seen}"
  end

  def direct_path(square)
    dirs = []

    row2, col2 = @ai.normalize(square.row, square.col)
    row1, col1 = @ai.normalize(self.row, self.col)

    if row1 < row2
      if row2 - row1 >= @ai.rows / 2
        dirs << :N
      else
        dirs << :S
      end
    end

    if row2 < row1
      if row1 - row2 >= @ai.rows / 2
        dirs << :S
      else
        dirs << :N
      end
    end

    if col1 < col2
      if col2 - col1 >= @ai.cols / 2
        dirs << :W
      else
        dirs << :E
      end
    end

    if col2 < col1
      if col1 - col2 >= @ai.cols / 2
        dirs << :E
      else
        dirs << :W
      end
    end

    dirs
  end

  def visible_squares
    @visible_squares ||= begin
      mx = Math.sqrt(self.ai.viewradius2).to_i
      offsets = []

      (-mx..mx+1).each do |drow|
        (-mx..mx+1).each do |dcol|
          d = drow**2 + dcol**2
          if d <= @ai.viewradius2
            offsets << { :row => drow%@ai.rows - @ai.rows, :col => dcol%@ai.cols - @ai.cols }
          end
        end
      end

      visible_array = []
      offsets.each do |offset|
        visible_array << @ai.map[offset[:row]+self.row][offset[:col]+self.col]
      end

      visible_array
    end
  end
end
