# Represents a single ant.
class AntEngine::Ant
	# Owner of this ant. If it's 0, it's your ant.
	attr_accessor :owner
	# Square this ant sits on.
	attr_accessor :square

	attr_accessor :alive, :ai

	def initialize alive, owner, square, ai
		@alive, @owner, @square, @ai = alive, owner, square, ai
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
		@ai.order self, direction
	end
end
