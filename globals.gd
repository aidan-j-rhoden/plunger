extends Node

## A dictonary storing the peer ids as keys and their usernames as values
@export var player_names = {}

## This array stores all the rooms currently being played
## An example would look like this:
##{
##	"room1": {"players": ["Joe", "Jane", "uncle Bob"], "level": "Station"},
##	"room2": {"players": ["same", "darn", "old", "name"], "level": "Death Hole"}
##}
@export var rooms = {}
