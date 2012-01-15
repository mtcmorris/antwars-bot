require 'ant_engine'
require 'util/logger'
require "mission"

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
    @my_hives = []
  end

  def run(ai)
    # your turn code here
    start_turn = Time.now
    @logger.log "Ran turn"
    food = food_squares(ai)

    detect_hives!(ai)
    mark_visible_squares!(ai)
    ai.missions.map(&:age)
    ai.missions.each do |mission|
      if !mission.active?(ai.my_ants)
        @logger.log "Mission inactive"
      end
    end
    ai.missions = ai.missions.reject(&:complete?).select{|m| m.active?(ai.my_ants) }

  	ai.my_ants.each do |ant|
  	  if (Time.now - start_turn) < 0.7
    	  nearest_food = food.sort{|a, b| b.distance(ant.square) <=> a.distance(ant.square)}.pop
    	  if nearest_food && nearest_food.distance(ant.square) < 80
      	  food = food - [nearest_food]
          move_via_pathfinder(ant, nearest_food, "food")
        elsif ant.on_mission?
          follow_mission(ant)
          ant.action_priority = 4
        elsif @enemy_hives.any? && ai.my_ants.count > 10
          ant.action_priority = 5
          closest_hive = @enemy_hives.sort{|a, b| b.distance(ant.square) <=> a.distance(ant.square)}.last
          move_via_pathfinder(ant, closest_hive, "attack")
    	  else
          most_unseen_square = ai.map.flatten.sort{|a, b| a.last_seen <=> b.last_seen}.last
          most_unseen_square.visible_squares.each{|sq|
            sq.last_seen = 0
          }
          ai.missions.push Mission.new(ant, most_unseen_square)
          follow_mission(ant)
          ant.action_priority = 3
  	    end
    	else
    	  @logger.log "Bailed on complex stuff as #{Time.now - start_turn}"
  	  end

      if !ant.moved? && ant.square.hill?
    		[:N, :E, :S, :W].shuffle.each do |dir|
    			if good_move?(ant.square.neighbor(dir))
            @logger.log "Got off hill"
            ant.order dir
    			end
    		end
  		end

      if !ant.moved?
        missionary_ants = ai.my_ants.select(&:action_priority).sort{|a, b| a.action_priority <=> b.action_priority }
        missionary_ants.each do |other_ant|
          if !ant.moved?
          # Re enforce
            move_naively(ant, other_ant.square, "Following ant")
          end
        end
  		end

  		if !ant.moved?
    		[:N, :E, :S, :W].shuffle.each do |dir|
    			if good_move?(ant.square.neighbor(dir))
            @logger.log "Went randomly"
            ant.order dir
    			end
    		end
  		end


      # We didn't move so mark square as taken
      (ant.square.destination = true ) if !ant.moved?
  	end

    raise "collieded" if(ai.my_ants.map(&:destination).compact.count != ai.my_ants.map(&:destination).compact.uniq.count)
  rescue Exception => e
      @logger.log "EXCEPTION #{e.to_s}"
      @logger.log caller.join("\n")
  end

  def move_via_pathfinder(ant, square, reason = "unknown")
    directions = ant.direction(square)
    if directions && good_move?(ant.square.neighbor(directions.first))
      dir = directions.first
      @logger.log "Ant is #{reason} #{dir.to_s} from #{ant.row},#{ant.col} to #{square.inspect} via pfinder"
      ant.order dir
    else
      @logger.log "Ant wanted to #{reason} #{dir.to_s} from #{ant.row},#{ant.col} to #{square.inspect} via pfinder but failed"
      move_naively(ant, square, reason)
    end
  end

  def follow_mission(ant)
    if ant.mission.duration > 10
      move_via_pathfinder(ant, ant.mission.goal, "Following extended mission")
    else
      move_naively(ant, ant.mission.goal, "Following mission duration #{ant.mission.duration}" )
    end
  end

  def move_naively(ant, square, reason = "unknown")
    directions = ant.square.direct_path(square)
    directions.shuffle.each do |dir|
      if good_move?(ant.square.neighbor(dir))
        @logger.log "Ant is #{reason} #{dir.to_s} from #{ant.row},#{ant.col} to #{square.inspect} naively"
        ant.order dir
      end
    end
  end

  def mark_visible_squares!(ai)
    ai.my_ants.map(&:square).map(&:visible_squares).flatten.uniq.each {|sq|
      sq.last_seen = 0
    }
  end

  def detect_hives!(ai)
    ai.map.flatten.each do |square|
      if square.enemy_hill? && !@enemy_hives.include?(square)
        @enemy_hives.push square
      end

      if square.my_hill? && !@my_hives.include?(square)
        @my_hives.push square
      end
    end
  end

  def good_move?(square)
    square.land? && !square.my_hill? && !square.destination? && !square.ant?
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
