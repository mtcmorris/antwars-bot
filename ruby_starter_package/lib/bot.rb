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
  	ai.my_ants.each do |ant|
  		# try to go north, if possible; otherwise try east, south, west.

  		[:N, :E, :S, :W].each do |dir|
  			if ant.square.neighbor(dir).land?
  				ant.order dir
  				break
  			end
  		end
  	end
  end
end
