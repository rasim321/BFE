extends Control

#Animations
onready var offender_sprite = $Offender_Sprite #the attacking sprite that's animated
onready var defender_sprite = $Defender_Sprite
onready var battle_platform = $grass_platform

#Stats
onready var offender_name = $Battle_Panel/Offender_Name_Text
onready var offender_health = $Battle_Panel/Offender_Health
onready var offender_hp_num = $Battle_Panel/Offender_HP_Num

onready var defender_name = $Battle_Panel/Defender_Name_Text
onready var defender_health = $Battle_Panel/Defender_Health
onready var defender_hp_num = $Battle_Panel/Defender_HP_Num

#Unit Stats UI


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



func battle_start(attack: Dictionary, defender: Enemy):
	
	$Missed_Label.visible = false
#	Attack is an animation sprite stored in "Offender_Sprite"
#	It comes in the form of a dictionary with damage and time (for modulation)
#	attributes
	
#	Defender is a unit and its defense attributes are sprite animations stored
#	in the "Defender_Sprite" node. The defense attribute points to which defender
#	animation will be played 
	
	var avoid = defender.get_tile_stats()[1]/100
	var defense = defender.get_tile_stats()[0]/100
	
	var hit_chance = attack['hit_chance'] - avoid
	var rand_roll = randf()
	
	
	if hit_chance > rand_roll:
		print("random roll:", rand_roll)
		visible = true
		offender_sprite.frame = 0
		#plays the animation that is stored in "offender_sprite"
		offender_sprite.position = attack["position"]
		
		offender_sprite.play(attack["name"])
		defender_sprite.play(defender.defense["name"])
		#the speed determines when the modulation happens in the defender
		yield(get_tree().create_timer(attack["speed"]), "timeout")
		defender_sprite.modulate = Color(4, 4, 4)
		yield(get_tree().create_timer(0.06), "timeout")
		defender_sprite.modulate = Color(1,1,1)
		for i in [0,5,-10,15,-5,+10,-15,0]:
			yield(get_tree().create_timer(0.005), "timeout")
			battle_platform.rect_position.x += i
			battle_platform.rect_position.y += i
			defender_sprite.position.x += i
			defender_sprite.position.y += i
		
		#Get the current damage and store it
		#Subtract the defense amount which is calculated from several factors
		#(currently only tile)
		current_damage = attack["damage"] * (1 - (defense/100)) #so here it's (1-0.10)
		
		
		tween.interpolate_property($Battle_Panel/Defender_Health, "value",
		 defender_health.value, defender_health.value-current_damage, 0.3)
		tween.start()
		
		tween.interpolate_property(self, "current_hp",
		defender_health.value, defender_health.value-current_damage, 0.3)
		tween.start()
		
		#Actually reduce the health of the defender
		update_health(defender)

	else:
		print(rand_roll)
		visible = true
		offender_sprite.frame = 0
		#plays the animation that is stored in "offender_sprite"
		offender_sprite.position = attack["position"]
		
		offender_sprite.play(attack["name"])
		defender_sprite.play(defender.defense["name"])
		
		yield(get_tree().create_timer(attack["speed"]-0.2), "timeout")
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
	if defender.health < 1:
		defender.queue_free()


var my_number : int = 0



func _on_Tween_tween_step(object, key, elapsed, value):
	if current_hp > 0:
		$Battle_Panel/Defender_HP_Num.text = str(current_hp)
	else:
		$Battle_Panel/Defender_HP_Num.text = str(0)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
