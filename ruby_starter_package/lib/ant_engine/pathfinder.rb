class Pathfinder
  class << self
    def table
      @table ||= []
    end

    def lookup(start, goal)
      path = table.detect { |p| p.include?(start) && p.include?(goal) }

      return if path.nil?

      start_idx = path.index(start)
      goal_idx  = path.index(goal)

      return start_idx > goal_idx ? path[goal_idx..start_idx].reverse : path[start_idx..goal_idx]
    end

    def cache(path)
      path.tap do |p|
        table << p
      end
    end
  end

  def initialize(start, goal)
    @start = start
    @goal = goal
  end

  def path
    if cached_path = self.class.lookup(@start, @goal)
      return cached_path
    end
    init_time = Time.new
    closed_set = []
    open_set = [@start]
    came_from = {}

    g_score = {@start => 0}
    h_score = {@start => @start.distance(@goal)}
    f_score = {@start => g_score[@start] + h_score[@start]}

    while open_set.any?
      x = open_set.sort_by { |a| f_score[a] }.first

      if x == @goal || (Time.new - init_time) > 0.02
        return self.class.cache(reconstruct_path(came_from, came_from[@goal]))
      end

      open_set.delete x
      closed_set << x

      x.neighbors.each do |y|
        next if closed_set.include? y

        tentative_g_score = g_score[x] + x.distance(y)

        if !open_set.include?(y)
          open_set << y
          tentative_is_better = true
        elsif tentative_g_score < g_score[y]
          tentative_is_better = true
        else
          tentative_is_better = false
        end

        if tentative_is_better
          came_from[y] = x
          g_score[y] = tentative_g_score
          h_score[y] = y.distance(@goal)
          f_score[y] = g_score[y] + h_score[y]
        end

      end

      #nodes_traversed += 1
    end

    raise RuntimeError, "could not find path from x:#{@start.col},y:#{@start.row} and x:#{@goal.col},y:#{@goal.row}"
  end

  def reconstruct_path(came_from, current_node)
    if came_from.has_key?(current_node)
      p = self.reconstruct_path(came_from, came_from[current_node])

      return p << current_node
    else
      return [current_node]
    end
  end
end