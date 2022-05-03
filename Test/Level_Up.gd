extends Control

onready var level_bg = $Level_Up_Bg
onready var level_num = $Level_Up_Bg/TextureRect/Level_Num
onready var character_name = $Level_Up_Bg/Char_Name

func level_up(unit):
	Experience.load()
	level_num.text = Experience[unit.char_name]["level"]
	character_name.text = unit.char_name
	
	


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
