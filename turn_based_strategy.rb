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

# Implementing Maps with Matrices
#
# In the Map class you're soing to need to store objects in a data
# structure indexed by x and y coordinates e.g map[x,y]
#
# if *map* was a regular array map[x,y] would return the element at 
# index x as well as the elements at index y
#
# Instead you'd like to get back an object from a 2D structure at the
# intersection of the x'th column and y'th row
#
# We build such a structure and name it *Matrix*
#
# It will be internally built ussing an instance of class Array that
# contains more instances of Array inside itself
# 

class Matrix
  def initialize(rows,cols )
    @rows = rows
    @cols = cols
    @data = []
    rows.times do |y|
      @data[y] = Array.new(cols)
    end
  end

  #NOTE: remember that y axis is actually the row axis direction
  #while x axis is the column direction
  def [](x,y)
    @data[y][x]
  end

  def []=(x,y, value)
    @data[y][x] = value
  end

  # method that returns all positions in the Matrix
  def all_positions

    # collect method is the same as map
    (0...@rows).collect do |y|
      (0...@cols).collect do |x|
        [x,y]
      end
    end.inject([]) { |a,b| a.concat b }
  end
end

matrix = Matrix.new(2,2)
p matrix.all_positions
