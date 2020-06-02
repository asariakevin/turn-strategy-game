# Turned Based Strategy 

## A strategy

Turn-based strategy games have their roots firmly in the world of board games

At the game's most fundamental, players alternate taking turns

During their turns, players maneuver their characters/minions aka *units* around a map
bringing them into conflict with other players' units

They may often claim resources or develop infrastructure on top of the
map as well

This game will be kept simple , more tactical than strategic, but by
the end we'll have a working turn-based strategy game back end that 
supports multiple GUI front ends

The key to decouple the game engine from the front end completely is
to carefully define the sorts of operations the GUI is going to have
to support and build a loosely coupled system

# What are the ways a player interacts with a turn-based strategy game?

First, the player observes the game, typically visually by looking at
a map
Textual descriptions are also involved

Second, the player must make a variety of choices typically regarding
movement and actions of the units the player controls
