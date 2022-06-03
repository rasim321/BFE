extends Control

#Portraits
var swordsman = preload("res://Test/common_portrait.png")
var axeman = preload("res://Test/axe_portrait.png")
var archer = preload("res://Test/archer_portrait.png")

#Names
onready var player_name = $Comp_Bg/Player_Name
onready var enemy_name = $Comp_Bg/Enemy_Name

#Player Stats
onready var player_hp = $Comp_Bg/Player_Stat_Cont/Pl_Hp
onready var player_mgt = $Comp_Bg/Player_Stat_Cont/Pl_Mgt
onready var player_hit = $Comp_Bg/Player_Stat_Cont/Pl_Hit
onready var player_crit = $Comp_Bg/Player_Stat_Cont/Pl_Crit

#Enemy Stats
onready var enemy_hp = $Comp_Bg/Enemy_Stat_Cont/En_Hp
onready var enemy_mgt = $Comp_Bg/Enemy_Stat_Cont/En_Mgt
onready var enemy_hit = $Comp_Bg/Enemy_Stat_Cont/En_Hit
onready var enemy_crit = $Comp_Bg/Enemy_Stat_Cont/En_Crit

#Portraits
onready var player_portrait = $Player_Portrait
onready var enemy_portrait = $Enemy_Portrait



func _ready():
	self.visible = false
	
func comp_stats(offender, defender):
	
#	Required variables
	var defender_tile_stats = defender.get_tile_stats()
	
	var tile_avoid = defender_tile_stats[1]/100
	var char_avoid = Experience.experience[defender.char_name]["speed"]/100
	var tile_defense = defender_tile_stats[0]/100
	
	var attack = offender.common_attack
	
	
	#Names
	player_name.text = offender.char_name
	enemy_name.text = defender.char_name
	
	#Health
	player_hp.text = str(offender.health)
	enemy_hp.text = str(defender.health)
	
	#Might
	#Enemy might is 0 for now but if counterattack is incorporated, this will change
	player_mgt.text = str((attack["damage"] + attack["weapon_damage"]) - \
		(Experience.experience[defender.char_name]["def"] + (tile_defense/2)))
	enemy_mgt.text = str(0)
	
	#Hit Chance
	#Enemy hit chance is 0 for now but may change if counterattack is incorporated
	player_hit.text = str((attack['hit_chance'] - (tile_avoid + char_avoid))*100)
	enemy_hit.text = str(0)
	
	#Crit Chance
	player_crit.text = str(0)
	enemy_crit.text = str(0)
	
	#Portraits
	match offender.war_class:
		"swordsman":
			player_portrait.texture = swordsman
		"axeman":
			player_portrait.texture = axeman
		"archer":
			player_portrait.texture = archer
		"spearman":
			player_portrait.texture = swordsman
			
	match defender.war_class:
		"swordsman":
			enemy_portrait.texture = swordsman
		"axeman":
			enemy_portrait.texture = axeman
		"archer":
			enemy_portrait.texture = archer
		"spearman":
			enemy_portrait.texture = swordsman
			

	self.visible = true

func hide_comp_stats():
	self.visible = false
