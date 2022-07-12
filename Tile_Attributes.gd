extends Node

#Platforms
var left_grass_platform = preload("res://Battle/left_grass_platform.tres")
var right_grass_platform = preload("res://Battle/right_grass_platform.tres")
var left_forest_platform = preload("res://Battle/left_forest_platform.tres")
var right_forest_platform = preload("res://Battle/right_forest_platform.tres")
var left_fort_platform = preload("res://Battle/left_fort_platform.tres")
var right_fort_platform = preload("res://Battle/right_fort_platform.tres")

#Scenery
var plains_scenery = preload("res://Battle/plains_background.tres")
var forest_scenery = preload("res://Battle/forest_background.tres")

var tile_attributes = {
	"Plain": [0,0], #defense, avoid
	"Forest": [10, 20], #defense, avoid
	"Fort" : [25, 30], #defense, avoid
	"River": [0,0], #defense, avoid
	"Obstacle": [0,0], #defense, avoid
	"Unknown": [0,0], #defense, avoid
	"Cliff": [0,0], #defense, avoid
	"Tree": [0,0], #defense, avoid
	"Mountain": [0,0] #defense, avoid
}

var tile_platforms ={
	"Plain" : [left_grass_platform, right_grass_platform],
	"Forest": [left_forest_platform, right_forest_platform],
	"Fort": [left_fort_platform, right_fort_platform]
}

var tile_scenery = {
	"Plain" : plains_scenery,
	"Forest": forest_scenery,
	"Fort" : plains_scenery
}
