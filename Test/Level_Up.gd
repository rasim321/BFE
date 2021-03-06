extends Control

onready var att_bg = $Level_Up_Bg/Att_Bg
onready var level_num = $Level_Up_Bg/Level_Num_Bg/Level_Num
onready var character_name = $Level_Up_Bg/Char_Name
onready var character_class = $Level_Up_Bg/Class
onready var tween = $Tween
var rng = RandomNumberGenerator.new()

func level_up(unit):
	rng.randomize()
	Experience.load()
	level_num.text = str(Experience.experience[unit.char_name]["level"])
	character_name.text = unit.char_name
	character_class.text = unit.war_class
	
	fade_in_out("in", 0.6)


	
	for key in Experience.growth[unit.char_name]:
		att_bg.get_node(key.capitalize()).text = str(key) + " : " + str(Experience.experience[unit.char_name][key])
		var rand_roll = rng.randf()
		if rand_roll > Experience.growth[unit.char_name][key]:
			att_bg.get_node(key.capitalize()).text = str(key) + " : " + str(Experience.experience[unit.char_name][key]) + "+" + str(1)
			Experience.experience[unit.char_name][key] += 1
			
	
	Experience.save()

		
	yield(get_tree().create_timer(3.5), "timeout")
	fade_in_out("out", 0.6)
#	self.visible = false
	

func fade_in_out(type : String, duration: float):
	
	if type == "in":
		self.modulate = Color(1,1,1,0)
		self.visible = true
		tween.interpolate_property(
		self, "modulate", 
		  Color(1, 1, 1, 0), Color(1, 1, 1, 1), duration, 
		  Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.start()

	elif type == "out":
		tween.interpolate_property(
		self, "modulate", 
		  Color(1, 1, 1, 1), Color(1, 1, 1, 0), duration, 
		  Tween.TRANS_LINEAR, Tween.EASE_IN)

		tween.start()
		yield(tween, "tween_all_completed")
		self.visible = false
		


# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
