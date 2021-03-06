extends Enemy
class_name Axeman

# Called when the node enters the scene tree for the first time.
func _on_ready():
	max_health = Experience.experience[char_name]["hp"]
	war_class = "axeman"
	$Swordman.visible = false
	$Axeman.visible = true
	animation_state.start("Axe_Idle")
#	set_process(false)
	effects.visible = false
	
	#Overriding common_attack and defense
	var axe_common_attack = {"name":"axeman_common_attack", "speed": [1.2],
	"damage": int(rand_range(round(Experience.experience[self.char_name]["str"]*0.9),
	round(Experience.experience[char_name]["str"]*1.1))), "position": Vector2(490,270),
	"hit_chance": 0.75,
	"weapon_damage" : items[char_name]["equipped"].might
	}
	
	var axe_defense = {"name":"axe_defender", "dodge": "axe_dodge"}
	
	common_attack = axe_common_attack
	defense = axe_defense
	crit_attack = axe_common_attack

	
	self.cell = grid.calculate_grid_position(position)
	self.position = grid.calculate_map_position(cell)
	print("Initial Player Position: ",cell)
	
	if not items.has(char_name):
		battle_menu.get_node("NinePatchRect/VBoxContainer/Item").disabled = true
	else:
		if len(items[char_name]["items"]) == 0:
			battle_menu.get_node("NinePatchRect/VBoxContainer/Item").disabled = true
	
	if not Engine.editor_hint:
		curve = Curve2D.new()
	
func _on_process():
#	animation_player.play("Idle")
	if _is_walking == false:
		animation_tree.set("parameters/Axe_Walk/blend_position", direction)
		self.animation_state.travel("Axe_Idle")
	else:
		animation_tree.set("parameters/Axe_Walk/blend_position", direction)
		self.animation_state.travel("Axe_Walk")

func animation_finished():
	_set_is_walking(false)
	animation_state.travel("Axe_Idle")


## Init refuse


#common_attack = {"name":"axeman_common_attack", "speed": 1.8,
#"damage": rng.randi_range(34,42)}
#
#func _init(
#axe_common_attack = {"name":"axeman_common_attack", "speed": 1.8,
#"damage": int(rand_range(34,42)), "position": Vector2(390,290),
#"hit_chance": 0.75
#},
# axe_defense = {"name":"axe_defender", "dodge": "axe_defender"}):
#	common_attack = axe_common_attack
#	defense = axe_defense
