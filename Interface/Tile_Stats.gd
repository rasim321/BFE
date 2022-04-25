extends Control

onready var tiletype = $Tile_HUD/Tile_Type
onready var defense = $Tile_HUD/Defense_Number
onready var avoid = $Tile_HUD/Avoid_Number

var tile_stats = {"Plain": [0,0], "Forest":[0,20]}
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _process(delta):
	pass
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func update_tile_stats(name, def, avo):
	tiletype.text = name
	defense.text = def
	avoid.text = avo
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
