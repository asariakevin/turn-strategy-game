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
  def initialize(rows,cols)
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

# Cartography 101
#
# The Map class will contain two matrices in instance variables
# one will hold Terrain instances while the other Unit instances
#
# Both will require accessors
#

class Map
  attr_reader :terrain , :units
end

# Both matrices will be the same size 
# The @units Matrix will start unpopulated and units will be added 
# using the *place* method


class Map
  def place(x,y, unit)

    @units[x,y] = unit
    unit.x = x
    unit.y = y
  end

  def move(old_x, old_y, new_x, new_y)
    raise LocationOccuppiedError.new(new_x, new_y) if @units[new_x, new_y]
    @unit[new_x,new_y] = @unit[old_x,old_y]
    @unit[old_x,old_y] = nil
  end
end

class LocationOccuppiedError < Exception
end

# Where does terrain come from?
# here we turn a string or file containing the layout into a *Map*
# The *initialize* method does this
#
# you start with a terrain key and a layout string
# then you break the text into lines to get your rows
# ignore any white space
#
# This is nice beacue it means you can have spaces at the 
# beginning of the lines if you have maps embedded in your source 
# code and want to tab indent them to level of the surrounding code
#
#
#

class Map

  def initialize(key, layout)
    rows = layout.split("\n" )
    rows.collect! { |row| row.gsub(/\s+/, '').split(//) }

    y = rows.size
    x = rows[0].size

    @terrain = Matrix.new(x,y)
    @units = Matric.new(x,y)

    rows.each_with_index do |row, y|
      row.each_with_index do |glyph, x|
        @terrain[x,y] = key[glyph]
      end
    end
  end
end


# Example
#
# terrain_key = {
# "f": forest
# "g": grass,
# "m": mountains,
# "p": plains
# "w": water
# }
#
#
# map = Map.new terrain_key, <<-END
#   ggggggggggggggg
#   ggggggggggggggg
#   ggggggggggwwwww
#   ggggggggggggggg
#   ggggggggggggggg
#   gggggggggpppppp
#   ggggggggggggggg
#   ggggggggggwwfff
#
#
# map.terrain[0,0],name -> Grass
#
#
# adding a few helper methods
#

class Map
  def all_positions
    @terrain.all_positions
  end

  # calculate whether the manhattan distance
  #between two points is less than a certain number
  def within?(distance, x1, y1, x2, y2)
    (x1 - x2).abs + (y1 - y2).abs <= distance
  end

  # returns a list of nearby locations
  def near_positions(distance, x,y)
    all_positions.find_all { |x2, y2| within?(distance, x,y, x2, y2) }
  end
end

# Representing a Map
#
# Since a *Map* consists of information about *Terrain* and *Unit*
# instances , we'll return a list containing each in turn
#

class Map
  def rep
    return [@terrain.rep, @units.rep]
  end
end

# to do the above we need a *rep* method for the *Matrix* class
#

class Matrix
  def rep
    @data.collect do |row|
      row.collect do |item|
        item.rep
      end
    end
  end
end

# since @units Matrix might have some nils nil needs a representation

class NilClass
  def rep
    nil
  end
end
