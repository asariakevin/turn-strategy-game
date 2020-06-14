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
# In the Map class you're going to need to store objects in a data
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
# It will be internally built using an instance of class Array that
# contains more instances of Array inside itself
 

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

#Units also can tell that another unit is an enemy if it is controlled
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

# Representing Units
#
# representations are limited to lists, strings, numbers and nil
# almost all of your representations will use at least one list as it
# is your only container object
#
# you'll almost always list the distinguishing type of the representation in the
# first position of the list


class Unit

  def rep
    [self.class.shortname, name]
  end
end

class Class
  # this returns the name of the class it is called on
  # unlike the name method on class, it strips any module prefixes out
  def shortname
    name.gsub(/^.*:/, '')
  end
end

# Example
# trex = TRex.new(player, "Johan")
# trex.rep => ["TRex", "Johan"]
#
#
#  Making Choices
#
# There are more features to add to your Unit class which all resolve
# around the notion of letting the player make choices
#
# e.g , your units have a *move* method but it's not enough to be 
# able to move
#
# the units have to present a list of movement choices
#
# you chould only present movement choices that are reachable given
# a unit's movement rate and it should only include valid coordinates
# on the map
#
# The representations for these movement choices will look like:
#
#   ["Move",2,3]
#   ["Move",3,2]
#
# the numbers being x and y coordinates respectively
#
# you need  a class to represent choices that will *bind* these representations to
# the actions that accompany them

class Choice 
  attr_reader :rep

  # using the special * prefix operator to inject a prebuilt list as
  # the representation
  def initialize(*rep, &action)
    @rep, @action =  rep, action
  end

  def call(*args, &proc)
    @action.call(*args,&proc)
  end
end

# Instances of the *Choice* class are created with a representation 
# and an action
#
# The representation can be accessed throught the *rep* method and
# the action can be triggered with the *call* method
#
# Here's an example
#
#   x , y = 0,1
#   choice = Choice.new("Move",x,y) { unit.move(x,y) }
#   choice.rep => ["Move",0,1]
#   choice.call
#
# you'll also define a constant Choice named DONE

DONE = Choice.new("Done")

# you'll use DONE to represent the player's desire to avoid a choice
# or finish making choices , see the section titles "The Players" for
# more information

# Finding Possible Moves
#
# Let's put the information about what moves are valid together with
# these Choice objects inside the Unit class

class  Unit

  def move_choices
    map = @player.game.map
    all = map.all_positions
    near = all.find_all { |x,y| map.within?(@movement, @x,@y,x,y) }
    valid = near.find_all { |x,y| map.units[x,y].nil? }
    return valid.collect do |x,y|
      Choice.new("Move",x,y) {self.move(x,y)}
    end
  end
end

# Choosing Among Actions
#
# Each Unit type will have a list of actions it can take after it moves
# The user will select one of the unit's actions and then potentially
# select among the possible ways to take that action
#
# Below is how the list of action choices is generated:

class Unit
  def action_choices
    return actions.collect do |action|
      # note the prefix * is used here for flattening
      Choice.new(*action.rep) { action }
    end
  end
end

# Taking Action
#
# Specific actions will be subclasses of the Action class
# Each subclass of the Action class will have its own representation
# available via the rep method
#
# Each will also have a method that will produce a list of instances
# of the class that represent the possible ways the action could be
# taken
#
# These instances will have their own representations and a call method that
# can be invoked to actually perform the actions


class Action
  def self.rep
    ["Action", self.class.shortname]
  end

  def self.range(unit); 1;end
  def self.target?(unit,other); unit.enemy?(other); end


  # Default Action generator assumes action is something you
  # do to the enemy standing next to you
  #
  # This behaviour will be overriden in many subclasses
  def self.generate(unit,game)
    map = game.map
    near = map.near_positions(range(unit), unit.x, unit.y)
    targets = near.find_all { |x,y| target?(unit, map.units[x,y]) }
    return targets.collect { |x,y| self.new(unit, game, x , y) }
  end
end

# following are the methods that will be called on the results
# returned from the generate class method
#
class Action
  attr_reader :unit, :game

  # an x and y coordinate is passed in to represent the
  # location of the action that could be performed
  #
  # this information is important to have around so you can pass it
  # to the interface so that it can present a spatial selection
  # mechanism
  def initialize(unit, game, x,y)
    @unit = unit
    @game = game
    @x = x
    @y = y
  end

  #since the generic Action superclass should never have its call
  #method invoked, you stub it out
  def call
    raise NotImplementedError
  end

  def target
    game.map.units[@x,@y]
  end

  # the representation will contain the name of the action and the
  # location it will occur at
  #
  # Action types that don't have a location should probably use the
  # loaction of the acting unit
  def rep
    [self.class.shortname, @x, @y]
  end
end


# implementing some Action subclasses
#

class Attack < Action
  def damage_caused(unit); raise NotImplementedError; end
  def past_tense; raise NotImplementedError; end

  def call
    amount = damage_caused()
    game.message_all("#{unit.name} #{past_tense} #{target.name} for #{amount} damage")
    target.hurt(amount)
  end
end

class Bite < Attack
  def damage_caused; @unit.teeth; end
  def past_tense; "bit"; end
end

class Shoot < Attack
  def self.range(unit); unit.range; end
  def damage_caused; @unit.caliber; end
  def past_tense; "shot"; end
end

class FirstAid < Action
  def self.target?(unit,other); unit.friend?(other); end
  def call
    target.hurt(-unit.heal)
    game.message_all("#{unit.name} healded #{target.name} for #{unit.heal} health")
  end
end

# the representation for a Bite instance looks like this
# ["Bite",0,1]

class Human < Unit
  attr_reader :caliber, :range

  def initialize(*args)
    super(*args)
    @actions << Shoot
    @caliber = 4
    @range = 3
  end
end

class Doctor < Human
  attr_reader :heal

  def initialize(*args)
    super(*args)
    @actions << FirstAid
    @heal = 2
  end
end

class Dinosaur < Unit
  attr_reader :teeth

  def initialize(*args)
    super(*args)
    @actions << Bite
    @teeth = 2
  end
end

class TRex < Unit
  def initialize(*args)
    @teeth = 5
  end
end

# The Players
#
# here we start by creating a base player class that provides the
# required infrastructure and then each different kind of player can 
# subclass 

class BasePlayer
  attr_reader :name
  attr_accessor :game

  def initialize(name)
    @name = name
    @units = []
  end

  def message(string); raise NotImplementedError; end
  def draw(map); raise NotImplementedError; end
  def do_choose; raise NotImplementedError; end
end

# at the minimum , each player needs a name and a reference to the
# master Game object
#
# you also need to keep track of a player's units
#
# the *game* instance variable is not set in the constructor because
# it is set via the accessor defined in the preceding code when a
# player is added to a game with *add_player*
#

class BasePlayer
  
  def add_unit(unit); @units.push unit; end
  def clear_units; @units = []; end
  def units_left?; @units.any? { |unit| unit.alive? }; end
  def new_turn; @units.each { |unit| unit.new_turn }; end
  def done; @game.message_all("Level finished"); end

  def unit_choices
    not_done = @units.find_all { |unit| unit.alive? && ! unit.done? }
    return not_done.map do |unit|
      Choice.new("Unit", unit.x, unit.y) { unit }
    end
  end
end

# Implementing the various choice methods will be the majority of the
# code

class BasePlayer
  def choose(choices, &block)
    do_choose(choices, &block) if choices?(choices)
  end

  def choices?(choices)
    !( choices.empty? || (choices.size == 1 && choices[0] == DONE) )
  end
end

class BasePlayer

  def choose_all(choices, &block)
    while choices?(choices)
      choose(choices) do |choice|
        block.call(choice)
        choices.delete(choice)
      end
    end
  end


  def choose_all_or_done(choices, &block)
    choices_or_done = choices.dup
    choices_or_done.push DONE
    choose_all(choices_or_done, &block)
  end

  def choose_or_done(choices, &block)
    choose_or_done = choices.dup
    choices_or_done.push DONE
    choose(choices_or_done, &block)
  end
end

# The Artificial Intelligence Doesn't Seem So Intelligent

class DumbComputer < BasePlayer
  def message(string)
  end

  def draw(map)
  end

  def do_choose(choices)
    yield choices[0]
  end
end

# an empty *message* method will be the  standard for computer players
# since they have little use for the niceties of the messages the 
# game sends out
#
# the computer's do_choose method just always selects the first choice
# of the options presented
#
#  Writing a Command-Line Player

require 'pp'
class CLIPlayer < BasePlayer
  def message(string)
    puts string
  end

  def draw(map)
    puts "Terrain:"
    pp map.terrain.rep
    puts "Units:"
    pp map.units.rep
  end
end

# implementing the *do_choose* method

class CLIPlayer 

  
  def do_choose(choices)

    # first call a helper method that builds a mapping between
    # the textual representations of choices and the choices themselves
    mapping = rep_mapping(choices)

    choice = nil

    # print all the representations from the mapping and wait for
    # command-line input
    # 
    # this input is then indexed into *rep_mapping* to retrueve
    # the choice the user selected
    #
    # if the input is bad, the process is repeated
    #
    # finally, when a choice is selected, *do_choose* invokes its code
    # block on the selected choice, which brings us to the *Game* class
    until choice
      puts "Choose: "
      puts mapping.keys

      print "Input: "
      choice_key = STDIN.gets
      choice = mapping[choice_key]

      puts "Bad choice" unless choice
    end

    yield choice
  end


  # builds a hash table from versions of the representations of the
  # choices converted into strings
  def rep_mapping(data)
    mapping = {}
    data.each do |datum|
      mapping[datum.rep.inspect] = datum
    end

    return mapping
  end
end

# The GAme
#
# The Game class is going to control your turn-based strategy game
#
# The base Game class will keep track of lists of maps and players as
# well as an index into each of the lists pointing to the current map
# and the player whose turn it is currently

class Game
  attr_reader :players

  def initialize
    @maps = []
    @on_start = []
    @players = []

    @map_index = 0
    @player_index = 0
    @done = false
  end

  def map; @maps[@map_index]; end
  def player; @players[@player_index]; end
  def next_map; @map_index += 1; end

  # as you rotate through the players , you expect to return to the
  # beginning again, to do so we modulo the index by the total 
  # number of players
  #
  # you don't need to worry about this for the maps because , when all
  # the maps have been played,you'd like the game to end
  #
  def next_player; @player_index = (@player_index + 1) % @players.size; end
  def start_map; @on_start[@map_index].call(map) if @on_start[@map_index]; end
end

# the *add_map* method not only add map to the game instance but it
# also takes in an optional block to be triggered using the *start_map* method
#
#The game's *turn* method will be able to invoke this callback for the
#currnt map using the *start* method
#this is useful for dynamically creating enemies for maps and laying
#out the units
#
class Game
  def add_map(map, &on_start)
    @maps.push map
    @on_start.push on_start
  end

  def add_player(player)
    @players.push player
    player.game = self
  end
end

# you also need a *done* method that notifies each player that the
# level is over and a *done?* method to check if the @done variable
# has been set

class Game
  def done
    players.each { |player| player.done }
    @done = true
  end

  def done?; @done; end
end

# you want methods to force all players to redraw their displays or
# display a message

class Game
  def draw_all
    @players.each { |player| player.draw(map) }
  end

  def message_all(text)
    @players.each { |player| player.message(text) }
  end
end

# implementing run
class Game
  def run
    message_all("Welcome to #{name}!")

    while true
      break unless map

      start_map
      until done?
        turn(player())
        next_player()
      end

      next_map
    end

    message_all("Thanks for playing.")
  end

end

# all the hard work is done inside the *turn* method that our subclasses must provide
# The *name* method will also be implemented there

class Game
  def turn
    raise NotImplementedError
  end

  def name
    raise NotImplementedError
  end
end


class DinoWars < Game
  def name
    return "DinoWars: WestWard Ho!"
  end

  def turn(player)

    player.new_turn

    draw_all()

    player.choose_all_or_done(player.unit_choices) do |choice|
      break if choice == DONE
      unit = choice.call

      draw_all()

      player.choose(unit.move_choices) do |move|
        move.call
      end

      draw_all()

      player.choose_or_done(unit.action_choices) do |choice|
        break if choice == DONE
        action = choice.call

        player.choose(action.generate(unit,self)) do |action_instance|
          action_instance.call
        end
      end

      unit.done

      draw_all()
    end

    done() unless players().find_all{ |player| player.units_left? }.size > 1
  end
end
