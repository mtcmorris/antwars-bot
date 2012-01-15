class Mission
  attr_accessor :goal, :current_row, :current_col, :duration
  def initialize(ant, goal)
    @duration = 0
    @current_row, @current_col, @goal = ant.row,  ant.col, goal
    ant.mission = self
  end

  def age
    @duration += 1
  end

  def complete?
    @current_row == goal.row && @current_col == goal.col
  end

  def active?(ants)
    @duration < 20 && ants.detect{|a| a.row == @current_row && a.col == @current_col }
  end

  def update(coords)
    @current_row, @current_col = *coords
  end
end