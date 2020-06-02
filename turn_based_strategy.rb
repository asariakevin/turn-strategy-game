# most strategy game play is tightly linked to the map
# the map keeps track of the terrain , distance and units(characters)
#
# the maps in this chapter will be represented with a 2D grid
# each square will have a slot for terrain type and for a unit
#
# all squares should have a terrain type , but many squares won't be
# occupied by a unit at any particular time
#
# terrain objects tell the game whether a square is covered in forest,
# mountains or rivers
#
#
# different Terrain types need to be presented distinctly in the interface . A name should be sufficient for this
#

class Terrain
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def rep
    [@name]
  end
end

# a Terrain is only distinguished by its name
#
# you'll be using these Terrain types to describe your map 
# you'll also need to keep track of both the terrain at any given 
# square and who if any is standing on it
#
# here we are only allowing one Unit to occupy a given square at a time
forest = Terrain.new("Forest")
grass = Terrain.new("Grass")
mountains = Terrain.new("Mountains")
plains = Terrain.new("Plains")
water = Terrain.new("Water")


