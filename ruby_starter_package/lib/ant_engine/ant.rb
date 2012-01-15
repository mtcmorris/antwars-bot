# Represents a single ant.
class AntEngine::Ant
	# Owner of this ant. If it's 0, it's your ant.
	attr_accessor :owner
	# Square this ant sits on.
	attr_accessor :square

	attr_accessor :alive, :ai

	def initialize alive, owner, square, ai
		@alive, @owner, @square, @ai = alive, owner, square, ai
		@moved = false
	end

	# True if ant is alive.
	def alive?; @alive; end
	# True if ant is not alive.
	def dead?; !@alive; end

	# Equivalent to ant.owner==0.
	def mine?; owner==0; end
	# Equivalent to ant.owner!=0.
	def enemy?; owner!=0; end

	# Returns the row of square this ant is standing at.
	def row; @square.row; end
	# Returns the column of square this ant is standing at.
	def col; @square.col; end

	# Order this ant to go in given direction. Equivalent to ai.order ant, direction.
	def order direction
	  @moved = true
		@ai.order self, direction
	end

	def position
	  Point.new(row, col)
  end

	def moved?; @moved; end

  def path_to(goal)
    #$stderr.puts "Start pathfinding: #{Time.now - @ai.start_time}"
    #$stderr.puts "path from #{self.square.row} #{self.square.col} to #{goal.row} #{goal.col}"
    path = Pathfinder.new(self.square, goal).path
    #$stderr.puts "Done pathfinding: #{Time.now - @ai.start_time}"
    return path
  end

  def direction(goal)
    @path ||= path_to(goal)
    @path.push(goal) if @path != false && !@path.include?(goal)
    if location = @path.index(self.square)
      direct_path(@path[location+1] || @path.last)
    else
      path = path_to(goal)
      return false if path.first.nil?
      direct_path(path[1] || path.first)
    end
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
end
