extends Control

onready var tween = $Tween

func _ready():
	pass # Replace with function body.

func phase_in():
	tween.interpolate_property(get_node("Turn_Background"), "modulate:a",  0, 0.67, 0.4, tween.TRANS_LINEAR,  tween.EASE_IN_OUT)
	tween.start()

