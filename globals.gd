extends Node

## This stores whether a game is curently playing.  This will probably be removed, as I hope to eventually impliment rooms.
@export var game_playing := false

## A dictonary storing the peer ids as keys and their usernames as values
@export var player_names = {}

@export var which_level = 0
