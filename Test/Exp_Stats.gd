extends Control


onready var char_name = $Exp_Bg/Name
onready var exp_bar = $Exp_Bg/Exp_Bar
onready var exp_num = $Exp_Bg/Exp_Num
onready var level_num = $Exp_Bg/Level_Num
onready var tween = $Tween
onready var level_bg = $Level_Up_Bg
# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	pass # Replace with function body.

func update_exp(unit, amount):
	self.visible = true
	level_num.text = "Level: " + str(Experience.experience[unit.char_name]["level"])
	char_name.text = unit.char_name
	
	tween.interpolate_property(exp_bar, "value",
		 Experience.experience[unit.char_name]["experience"] - amount, Experience.experience[unit.char_name]["experience"], 0.3)
	tween.start()
	yield(get_tree().create_timer(0.8), "timeout")
	self.visible = false
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Tween_tween_step(object, key, elapsed, value):
	exp_num.text = str(exp_bar.value)
	pass # Replace with function body.
