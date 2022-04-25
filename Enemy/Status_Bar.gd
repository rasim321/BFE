extends Control

onready var tween = $Tween


# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	$RichTextLabel.text = get_parent().get_parent().char_name
	$TextureRect/TextureProgress.max_value = get_parent().get_parent().max_health
	$TextureRect/TextureProgress.value = get_parent().get_parent().health
	
	print("max_health", get_parent().get_parent().max_health)
	print("health", get_parent().get_parent().health)
	
	# Replace with function body.

func tween_health_status(amount):
	self.visible = true
	tween.interpolate_property($TextureRect/TextureProgress, "value",
	get_parent().get_parent().health - amount, get_parent().get_parent().health, 0.3)
	tween.start()
	print("max_health", get_parent().get_parent().max_health)
	print("health", get_parent().get_parent().health)
	yield(get_tree().create_timer(0.9), "timeout")
	self.visible = false
	


func _on_Tween_tween_step(object, key, elapsed, value):
	if get_parent().get_parent().health > 0:
		$TextureRect/Hp_Num.text = str(get_parent().get_parent().health)
	else:
		$TextureRect/Hp_Num.text = str(0)
