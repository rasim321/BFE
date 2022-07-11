extends Enemy
class_name Archer


# Called when the node enters the scene tree for the first time.
func _on_ready():
	max_health = Experience.experience[char_name]["hp"]
	war_class = "archer"
	$Swordman.visible = false
	$Axeman.visible = false
	$Archer.visible = true
	animation_state.start("Archer_Idle")
#	set_process(false)
	rng.randomize()
	effects.visible = false
	Experience.save()
	
	#overriding common_attack and defense
	var archer_common_attack = {"name":"archer_common_attack", "speed": [2.5],
	"damage": int(rand_range(round(Experience.experience[self.char_name]["str"]*0.9),
	round(Experience.experience[char_name]["str"]*1.1))), "position": Vector2(570,300),
	"hit_chance": 0.85,
	"weapon_damage" : items[char_name]["equipped"].might
	}
	var archer_defense = {"name":"archer_defender", "dodge": "archer_dodge"}
	
	common_attack = archer_common_attack
	defense = archer_defense
	crit_attack = archer_common_attack
	
	
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
		animation_tree.set("parameters/Archer_Walk/blend_position", direction)
		self.animation_state.travel("Archer_Idle")
	else:
		animation_tree.set("parameters/Archer_Walk/blend_position", direction)
		self.animation_state.travel("Archer_Walk")

func animation_finished():
	_set_is_walking(false)
	animation_state.travel("Archer_Idle")

func _on_Attack_pressed():
	battle_menu.visible = false
	#randomization of attack damage
	rng.randomize()
	connect('attack_selected', get_parent(), "enemy_attack_selected")
	emit_signal("attack_selected", "archer")


## Refuse of _init
#func _init(
#archer_common_attack = {"name":"archer_common_attack", "speed": 2.5,
#"damage": 28, "position": Vector2(570,300),
#"hit_chance": 0.85,
#"weapon_damage" : items[char_name]["equipped"].might
#},
#
# archer_defense = {"name":"archer_defender", "dodge": "archer_dodge"}
#
#):
#	common_attack = archer_common_attack
#	defense = archer_defense
