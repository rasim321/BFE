extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	self.hide()
#	print("Camera is:", camera)
	pass # Replace with function body.
	
func show_stats():
	self.show()

func hide_stats():
	self.hide()

func update_stats(name, health, max_health, max_mana, mana, war_class):
	$Name.text = name
	$HealthBar.max_value = max_health
	$HealthBar.value = health
	$ManaBar.max_value = max_mana
	$ManaBar.value = mana
	$War_Class.text = war_class
	

