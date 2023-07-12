## These are the global variables for the entire game.  Most of them are only for the server.
extends Node

## A dictonary storing the peer ids as keys and their usernames as values
@export var player_names = {}

## An array of all avaliable levels
@export var levels = {"0": "res://maps/map_test.tscn", "1": "res://maps/test_map_2.tscn", "2": "res://maps/test_map_3.tscn", "3": "res://maps/test_level_4.tscn"}

## This array stores all the rooms currently being played
## An example would look like this:
##{
##	"room1": {"players": ["Joe", "Jane", "uncle Bob"], "level": "Station"},
##	"room2": {"players": ["same", "darn", "old", "name"], "level": "Death Hole"}
##}
@export var rooms = {}
