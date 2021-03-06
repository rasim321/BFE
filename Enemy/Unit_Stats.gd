extends Control

var swordsman = preload("res://Test/common_portrait.png")
var axeman = preload("res://Test/axe_portrait.png")
var archer = preload("res://Test/archer_portrait.png")

var health_potion = preload("res://Enemy/health_potion.tres")
var iron_sword = preload("res://Enemy/iron_sword.tres")
var iron_axe = preload("res://Enemy/iron_axe.tres")
var iron_bow = preload("res://Enemy/iron_bow.tres")

onready var items = $"/root/GlobalInventory".inventory 

# Called when the node enters the scene tree for the first time.
func _ready():
	self.hide()
#	print("Camera is:", camera)
	pass # Replace with function body.
	
func show_stats():
	self.show()

func hide_stats():
	self.hide()

func update_stats(name, health, max_health, war_class):
	$Name.text = name
	$HealthBar.max_value = max_health
	$HealthBar.value = health
	$War_Class.text = war_class.capitalize()
	
	match war_class:
		"swordsman":
			$Portrait_Container/Portrait.texture = swordsman
		"axeman":
			$Portrait_Container/Portrait.texture = axeman
		"archer":
			$Portrait_Container/Portrait.texture = archer
	
	$Weapon_Texture.texture = items[name]['equipped'].texture
		
	

