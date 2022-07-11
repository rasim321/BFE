extends Control

#Animations
onready var offender_sprite = $Offender_Sprite #the attacking sprite that's animated
onready var defender_sprite = $Defender_Sprite
onready var left_battle_platform = $left_platform
onready var right_battle_platform = $right_platform

#Stats
onready var offender_name = $Battle_Panel/Offender_Name_Text
onready var offender_health = $Battle_Panel/Offender_Health
onready var offender_hp_num = $Battle_Panel/Offender_HP_Num

onready var defender_name = $Battle_Panel/Defender_Name_Text
onready var defender_health = $Battle_Panel/Defender_Health
onready var defender_hp_num = $Battle_Panel/Defender_HP_Num

#Signals
signal premature_death


#Battle_Status
var battle_status = false

#Current_Damage
#for offender
var current_damage : int
#for defender
var current_hp : int

#Tween
onready var tween = $Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	pass # Replace with function body.



func battle_start(attack: Dictionary, defender: Enemy, attacker: Enemy):
	
	$Missed_Label.visible = false
#	Attack is an animation sprite stored in "Offender_Sprite"
#	It comes in the form of a dictionary with damage and time (for modulation)
#	attributes
	
#	Defender is a unit and its defense attributes are sprite animations stored
#	in the "Defender_Sprite" node. The defense attribute points to which defender
#	animation will be played 
	
	#Getting the defender_tile_stats into a variable: defense, avoid, platform
	var defender_tile_stats = defender.get_tile_stats()
	var tile_avoid = defender_tile_stats[1]/100
	var tile_defense = defender_tile_stats[0]/100
	
	#Character speeds
	var char_avoid = Experience.experience[defender.char_name]["speed"]/100
	
	#For Ryn, the offender sprite will be scaled down
	#This is to adjust the sprite size for some characters
	if attack.has("scale"):
		$Offender_Sprite.scale = attack["scale"]
		
	#For Ryn, as defender, the scale ahs to be reduced
	if defender.defense.has("scale"):
		$Defender_Sprite.scale = defender.defense["scale"]
	
	#Defender positioning
	match defender.war_class: 
		"swordsman":
			$Defender_Sprite.position = Vector2(410,320)
		"archer", "axeman", "spearman":
			$Defender_Sprite.position = Vector2(411,300)

	
	#For Archers, the platforms will be slightly apart
	if attacker.war_class == "archer":
		#The first texture is the defender's (on the left)
		#The second texture is the attacker's (on the right)
		left_battle_platform.texture = defender_tile_stats[2][0].texture
		left_battle_platform.rect_position.x -= 20
		
		#For the attacker, we are feeding the tile texture from the gameboard -- from the last cell
		if len(get_parent().get_parent().astar_path.path) != 0:
			right_battle_platform.texture = attacker.get_tile_stats(get_parent().get_parent().astar_path.path[-1])[2][1].texture
		else:
			right_battle_platform.texture = attacker.get_tile_stats(attacker.cell)[2][1].texture
		right_battle_platform.rect_position.x += 20
	else:
		
		left_battle_platform.texture = defender_tile_stats[2][0].texture
		left_battle_platform.rect_position.x = 194
		#For the attacker, we are feeding the tile texture from the gameboard -- from the last cell
		if len(get_parent().get_parent().astar_path.path) != 0:
			right_battle_platform.texture = attacker.get_tile_stats(get_parent().get_parent().astar_path.path[-1])[2][1].texture
		else:
			right_battle_platform.texture = attacker.get_tile_stats(attacker.cell)[2][1].texture
		right_battle_platform.rect_position.x = 527
	
	var hit_chance = attack['hit_chance'] - (tile_avoid + char_avoid)
	
	#Check if the speed of the attacker is more than 3 of the defender
	#In this case, double the attack
	var att_num = 1
	if Experience.speed_diff(attacker.char_name, defender.char_name):
		att_num = 2
	
	for number_of_attacks in range(att_num):

		var rand_roll = randf()
		
		#Wait for the first animation to finish before the second attack occurs
		if number_of_attacks == 1:
			yield(offender_sprite, "animation_finished")
			offender_sprite.frame = 0
		
		
		
		if hit_chance > rand_roll:
			print("random roll:", rand_roll)
			visible = true
			offender_sprite.frame = 0
			#plays the animation that is stored in "offender_sprite"
			offender_sprite.position = attack["position"]
#			defender_sprite.position = Vector2(419,299)
			
			offender_sprite.play(attack["name"])
			defender_sprite.play(defender.defense["name"])
			#the speed determines when the modulation happens in the defender
			
			var time_counter : float = 0
			for mod_time in attack["speed"]:
				
				yield(get_tree().create_timer(mod_time - time_counter), "timeout")

				defender_sprite.modulate = Color(4, 4, 4)
				yield(get_tree().create_timer(0.06), "timeout")
				time_counter += mod_time + 0.06
				
				defender_sprite.modulate = Color(1,1,1)
				for i in [0,5,-10,15,-5,+10,-15,0]:
					yield(get_tree().create_timer(0.005), "timeout")
				

					left_battle_platform.rect_position.x += i
					left_battle_platform.rect_position.y += i
					right_battle_platform.rect_position.x += i
					right_battle_platform.rect_position.y += i
					defender_sprite.position.x += i
					defender_sprite.position.y += i
				time_counter += 0.035

			
			
			
			#Get the current damage and store it
			#Subtract the defense amount which is calculated from several factors
			#(currently only tile)
			current_damage = (attack["damage"] + attack["weapon_damage"]) - \
			(Experience.experience[defender.char_name]["def"] + (tile_defense/2)) 
			
			print( attack["damage"])
			print("minus")
			print(Experience.experience[defender.char_name]["def"]/2)
			
			tween.interpolate_property($Battle_Panel/Defender_Health, "value",
			 defender_health.value, defender_health.value-current_damage, 0.3)
			tween.start()
			
			tween.interpolate_property(self, "current_hp",
			defender_health.value, defender_health.value-current_damage, 0.3)
			tween.start()
			
			#Actually reduce the health of the defender
			update_health(defender)
			
			#Check to see if defender dies from first attack
			if defender.health < 1:
				#changed it here from break
				emit_signal("premature_death", true)
				break
			else:
				emit_signal("premature_death", false)

		else:
			print(rand_roll)
			visible = true
			offender_sprite.frame = 0
			#plays the animation that is stored in "offender_sprite"
			offender_sprite.position = attack["position"]
			
			offender_sprite.play(attack["name"])
#			defender_sprite.position = Vector2(419,299)
			defender_sprite.play(defender.defense["name"])
			
			yield(get_tree().create_timer(attack["speed"][0]-0.2), "timeout")
			$Missed_Label.visible = true
			defender_sprite.play(defender.defense['dodge'])
			yield(defender_sprite, "animation_finished")
			$Missed_Label.visible = false
			defender_sprite.play(defender.defense["name"])

		
	yield(offender_sprite, "animation_finished")
	offender_sprite.frame = 0
	visible = false

	


func battle_stats(offender, defender):
	offender_name.text = offender.char_name
	offender_health.max_value = offender.max_health
	offender_health.value = offender.health
	offender_hp_num.text = str(offender.health)
	
	defender_name.text = defender.char_name
	defender_health.max_value = defender.max_health
	defender_health.value = defender.health
	defender_hp_num.text = str(defender.health)
	

func update_health(defender):
	defender.health = defender.health - current_damage

signal remove_unit

func death(defender):
	if defender.health < 1:
		defender.queue_free()
		get_parent().get_parent()._units.erase(defender)
		emit_signal("remove_unit", defender)
		

func _on_Tween_tween_step(object, key, elapsed, value):
	if current_hp > 0:
		$Battle_Panel/Defender_HP_Num.text = str(current_hp)
	else:
		$Battle_Panel/Defender_HP_Num.text = str(0)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
