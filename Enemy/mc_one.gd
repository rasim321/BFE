extends Enemy

class_name MC_ONE

onready var sprite_scale = get_parent().get_node("HUD/Battle_Scene/Offender_Sprite").scale 

# Called when the node enters the scene tree for the first time.
func _on_ready():
	max_health = Experience.experience[char_name]["hp"]
	war_class = "Assassin"
	$Swordman.visible = false
	$Axeman.visible = false
	$Archer.visible = false
	$Assassin.visible = true
	
	animation_state.start("MC_ONE_Idle")
#	set_process(false)
	rng.randomize()
	effects.visible = false
	Experience.save()
	

	
	#overriding common_attack and defense
	var mc_one_common_attack = {"name":"mc_one_common_attack", "speed": [1,1.8],
	"damage": int(rand_range(round(Experience.experience[self.char_name]["str"]*0.9),
	round(Experience.experience[char_name]["str"]*1.1))), "position": Vector2(550,290),
	"hit_chance": 0.9,
	"weapon_damage" : items[char_name]["equipped"].might,
	"scale" : Vector2(3.5,3.5) #this is to adjust the sprite size
	}
	var mc_one_defense = {"name":"mc_one_defender", "dodge": "mc_one_dodge", "scale" : Vector2(3.2,3.2)}
	
	common_attack = mc_one_common_attack
	defense = mc_one_defense
	
	
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
		animation_tree.set("parameters/MC_ONE_Walk/blend_position", direction)
		self.animation_state.travel("MC_ONE_Idle")
	else:
		animation_tree.set("parameters/MC_ONE_Walk/blend_position", direction)
		self.animation_state.travel("MC_ONE_Walk")

func animation_finished():
	_set_is_walking(false)
	animation_state.travel("MC_ONE_Idle")

func _on_Attack_pressed():
		#scaling the attack animations down
	battle_menu.visible = false
	#randomization of attack damage
	rng.randomize()
	connect('attack_selected', get_parent(), "enemy_attack_selected")
	emit_signal("attack_selected")
