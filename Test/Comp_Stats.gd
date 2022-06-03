extends Control

var player_name = $Comp_Bg/Player_Name.text
var enemy_name = $Comp_Bg/Enemy_Name.text



func _ready():
	self.visible = false
	
func comp_stats(player, enemy):
	player_name = player.char_name
	enemy_name = enemy.char_name
	self.visible = true

