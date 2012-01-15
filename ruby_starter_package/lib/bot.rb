require 'ant_engine'
require 'util/logger'

if `whoami`.chomp == "mtcmorris"
  require "rubygems"
  require "ir_b"
end

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
    @enemy_hives = []
    @past_postions = []
    @persistant_ants = ai.my_ants
  end

  def run(ai)
    # your turn code here
    start_turn = Time.now
    @logger.log "Ran turn"

    @destinations = []
    food = food_squares(ai)
    @logger.log food.inspect

    # Point.new(ai.my_ants.first.row, ai.my_ants.first.col).path()
  	ai.my_ants.each do |ant|
  	  if (Time.now - start_turn) < 0.6
    	  nearest_food = food.sort{|a, b| b.distance(ant.square) <=> a.distance(ant.square)}.pop
    	  if nearest_food && nearest_food.distance(ant.square) < 60
      	  food = food - [nearest_food]
          dir = ant.direction(nearest_food).first
          if dir && good_move?(ant.square.neighbor(dir))
            @logger.log "Ant is moving #{dir.to_s} from #{ant.row},#{ant.col} to #{nearest_food.inspect} via pfinder"
            add_destination(ant.order dir)
          else
            @logger.log "Ant wanted to move #{dir.to_s} from #{ant.row},#{ant.col} to #{nearest_food.inspect} via pfinder but was bad"
          end
    	  end
    	else
    	  @logger.log "Bailed on complex stuff as #{Time.now - start_turn}"
  	  end

      if !ant.moved?
        # Can I move to a new position?
        [:N, :E, :S, :W].shuffle.each do |dir|
          coords = [ant.square.neighbor(dir).row, ant.square.neighbor(dir).col];
          if good_move?(ant.square.neighbor(dir)) && @past_postions.select{|p| p == coords }.empty?
            @logger.log "Ant moved somewhere new"
            add_destination(ant.order dir)
    				break
  				end
        end
      end

      if !ant.moved?
    		[:N, :E, :S, :W].shuffle.each do |dir|
    			if good_move?(ant.square.neighbor(dir))
            @logger.log "Ant moved randomly"
            add_destination(ant.order dir)
    				break
    			end
    		end
  		end
  	end
  rescue Exception => e
    @logger.log "EXCEPTION #{e.to_s}"
  end

  def add_destination(coords)
    @destinations.push coords
    @past_postions.push(coords) unless @past_postions.include?(coords)
  end

  def good_move?(square)
    square.land? && !square.ant? && @destinations.select{|d| d[0] == square.row && d[1] == square.col }.empty?
  end

  def distance(coord1, coord2)
    Math.sqrt(
      (coord1[0] - coord2[0]).abs ** 2 + (coord1[1] - coord2[1]).abs ** 2
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
    vector.shuffle
  end

  def food_squares(ai)
    food_coords = []
    ai.map.each { |r|
      r.each{|c|
        if c.food
          food_coords.push c
        end
      }
    }
    food_coords
  end
end
