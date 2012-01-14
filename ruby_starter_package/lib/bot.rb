require 'ant_engine'
require 'util/logger'

class Bot
  def self.run(ai = AntEngine::AI.new)
    bot = new
    ai.setup do |ai|
    	bot.setup ai
    end

    ai.run do |ai|
    	bot.run ai
    end
  end

  def setup(ai)
    @logger = Logger.new
  end

  def run(ai)
    # your turn code here
    @logger.log "Ran turn"
    # Get food locations
    food = food_locations(ai)
    @logger.log food.inspect
  	ai.my_ants.each do |ant|
  	  food_to_move_to = food.sort{|a, b| distance(b, [ant.row, ant.col]) <=> distance(a, [ant.row, ant.col])}.pop
  	  if food_to_move_to
    	  vector = get_vector(food_to_move_to, [ant.row, ant.col])
    	  vector.each{|dir|
          if ant.square.neighbor(dir).land? && !ant.square.neighbor(dir).ant?
            ant.order dir
            break
          end
    	  }
  	  end

      if !ant.moved?
    		# Move randomly

    		[:N, :E, :S, :W].shuffle do |dir|
    			if ant.square.neighbor(dir).land? && !ant.square.neighbor(dir).ant?
    				ant.order dir
    				break
    			end
    		end
  		end
  	end
  end

  def distance(coord1, coord2)
    Math.sqrt(
      (coord1[0] - coord2[0]).abs ** 2
        +
      (coord1[1] - coord2[1]).abs ** 2)
    )
  end

  def get_vector(coord1, coord2)
    vector = []
    if coord1[0] < coord2[0]
      vector.push :N
    elsif coord1[0] > coord2[0]
      vector.push :S
    end

    if coord1[1] < coord2[1]
      vector.push :W
    elsif coord1[0] > coord2[0]
      vector.push :E
    end
    vector
  end

  def food_locations(ai)
    food_coords = []
    ai.map.each { |r|
      r.each{|c|
        if c.food
          food_coords.push [c.row, c.col]
        end
      }
    }
    food_coords
  end
end
