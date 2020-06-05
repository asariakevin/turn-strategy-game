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
    @units[new_x,new_y] = @units[old_x,old_y]
    @units[old_x,old_y] = nil
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
    @units = Matrix.new(x,y)

    rows.each_with_index do |row, y|
      row.each_with_index do |glyph, x|
        @terrain[x,y] = key[glyph]
      end
    end
  end
end


# Example
#
 terrain_key = {
 "f" =>  forest,
 "g" =>  grass,
 "m" => mountains,
 "p" => plains,
 "w" => water
 }
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

layout = <<-EOM
   ggggggggggggggg
   ggggggggggggggg
   ggggggggggwwwww
   ggggggggggggggg
   ggggggggggggggg
   gggggggggpppppp
   ggggggggggggggg
   ggggggggggwwfff
EOM
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

# Meeting Your Heroes
#
# we need some classes to represent both the player's characters as
# well as the enemy dinosaurs

class Unit; end

class Human < Unit; end
class Soldier < Human; end
class Doctor < Human; end

class Dinosaur < Unit ; end
class VRaptor < Dinosaur; end
class TRex < Dinosaur ; end

# The Universal Skeleton
#
# all Unit classes have a name and a health counter
#

class Unit
  attr_reader :name, :health, :movement, :actions
  attr_accessor :x, :y

  def initialize(player, name)
    # player represents either a human or a computer that controls
    # a team of units
    #
    # Player objects also provide access to the *Game* object through
    # the game method
    #
    # Once you have a reference to the *Game*, you can script anything
    # you need
    @player = player
    @name = name
    @health = 10
    @movement = 2
    @actions = []
  end
end

# since units have health points , you'll want a way for units to be
# injured as well
#
# the following additions make that possible as well as opening the
# door for subclasses to perform special behaviour upon death

class Unit
  def hurt(damage)
    #Units that are dead can't take any more damage
    return if dead?
    @health -= damage
    die if dead?
  end


  # Units are considered dead if they have 0 or fewer hit points
  def dead?
    return @health <= 0
  end

  def alive?
    return !dead?
  end

  def die
    player.game.message_all("#{name} died")
  end
end

#Units also can tell that another unit is an ene,y if it is controlled
#by another player or that a unit is a friend if it is controlled by
#the same player
#

class Unit
  def enemy?(other)
    (other != nil) && (player != other.player)
  end

  def friend?(other)
    (other != nil) && (player == other.player)
  end
end

# Units also keep track of whether they've already acted this turn
class Unit
  def done?; @done ; end
  def done; @done = true;end
  def new_turn; @done = false ; end
end

# Units also move, the move method will take absolute coordinates to
# make things easy
class Unit
  def move(x,y)
    @player.game.map.move(@x,@y, x,y)
    @x = x
    @y = y
  end
end

# Stubbing Out Undefined classes
#
# Because you haven't written your Game classes or classes to represent your players
# you can't run the preceding code
#
# However , if you're willing to 'stub out' the missing classes with
# a bare minimum of functionality , you can at least try out some of
# the code

class FakeGame
  attr_accessor :map
end

class FakePlayer
  attr_accessor :game
end

# This is enough to create a fake player and game to use with your units

player = FakePlayer.new
player.game = FakeGame.new
player.game.map = Map.new(terrain_key, layout)
dixie = Unit.new(player,"Dixie")
player.game.map.place(0,0,dixie)
dixie.move(1,0)
