extends Node2D

class_name Enemy

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
const DIAGONALS = [Vector2(1,1), Vector2(1,-1), Vector2(-1,1), Vector2(-1,-1)]

export var grid: Resource = preload("res://World/Grid.tres")
onready var _path_follow: PathFollow2D = $PathFollow2D


onready var path2D = get_node("Path2D")
onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")
onready var direction : Vector2
onready var tween = $Tween
onready var camera = $Camera2D
onready var battle_menu = $Battle_Node/Battle_Menu
onready var item_menu = $Battle_Node/Item_Menu
onready var status_bar = $Battle_Node/Status_Bar
onready var curve = Curve2D
onready var tile_background = get_parent().get_node("Background")
onready var tile_objects = get_parent().get_node("Objects")
onready var tile_attributes = $"/root/TileAttributes".tile_attributes
#Random Number generator
var rng = RandomNumberGenerator.new()

onready var effects = $effects

#Character Data
export var char_name : String

onready var max_health : int = Experience.experience[char_name]["hp"]
onready var health : int = max_health
export var war_class : String
onready var move_range : int = Experience.experience[char_name]["move"]
export var notice_range := 6
export var move_speed := 600.0
onready var attack_stat : int = Experience.experience[char_name]["str"]
export var playable = true
export var player_char : bool


#Attacks
var common_attack = {"name":"goon_common_attack", "speed": 1.4,
"damage": int(rand_range(26,34)), "position": Vector2(390,308),
"hit_chance": 0.8}

#Defense
var defense = {"name":"common_defender", "dodge":"common_dodge"}

#Items
onready var items = $"/root/GlobalInventory".inventory
onready var item_action = $Battle_Node/Item_Menu/Item_Action_Bg

#Experience


#var axe_comon_attack = {"name":"axeman_common_attack", "speed": 1.8,
#"damage": rng.randi_range(34,42)}

func add_experience(action, on : Enemy = null):
	
	var new_exp = 0
	
	Experience.load()
	match action:
		"attack":
			new_exp = 15 * Experience.experience[on.char_name]["level"] - Experience.experience[self.char_name]["level"]
			Experience.experience[self.char_name]["experience"] += new_exp
		"item_use":
			new_exp = 10
			Experience.experience[self.char_name]["experience"] += new_exp
		"kill":
			pass
			new_exp = 30 * Experience.experience[on.char_name]["level"] - Experience.experience[self.char_name]["level"]
			Experience.experience[self.char_name]["experience"] += new_exp
	
	Experience.save()
	emit_signal("add_experience", self, new_exp)

	
	if Experience.experience[self.char_name]["experience"] > 99:
		level_up()

	
func level_up():
	effect_triggered("Level Up")
	Experience.experience[self.char_name]["level"] += 1
	Experience.experience[self.char_name]["experience"] = 0
	Experience.save()
	self.connect("level_up", get_parent(), "_on_Level_Up",[self])
	yield(get_tree().create_timer(1.2), "timeout")
	emit_signal("level_up")
	

	
	


	
			

#Signals
#signal to GameTest board when wait is selected from the battle menu
signal wait_selected
signal attack_selected
signal item_selected
signal item_engaged
signal add_experience
signal level_up
#Signal connections


#onready var _anim_player = $AnimatedSprite
var cell := Vector2.ZERO setget set_cell
var is_selected := false setget set_is_selected
var _is_walking := false setget _set_is_walking

func set_cell(value):
	cell = grid.clamp(value)
	
func set_is_selected(value):
	is_selected = value
	if is_selected == true:
		get_node("Swordman").modulate = Color(1.10,1.05,0)
	else:
		get_node("Swordman").modulate = Color(1,1,1)
#	if is_selected:
#		_anim_player.play("idle")
#		print("player selected")
#	else:
#		_anim_player.play("common")
		
func _set_is_walking(value):
	_is_walking = value
	set_process(_is_walking)
	
signal walk_finished

func _ready() -> void:
	$Battle_Node.visible = true
	_on_ready()

func _on_ready():
	$Swordman.visible = true
	$Axeman.visible = false
	animation_state.start('Idle')
	effects.visible = false
	
	#This is momentarily keeping the experience from getting too high
	Experience.save()
	Experience.load()
	
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
		


func walk_along(path: PoolVector2Array):
	pass

func move_player(start : Vector2, end : Vector2, speed: float):
	tween.interpolate_property(self, "position", start, end, speed, tween.TRANS_LINEAR,  tween.EASE_IN_OUT)
	tween.start()
	
func _process(delta: float) -> void:
	_on_process()
#	animation_player.play("Idle")
	

func _on_process():
	if _is_walking == false:
		animation_tree.set("parameters/Walk/blend_position", direction)
		self.animation_state.travel("Idle")
	else:
		animation_tree.set("parameters/Walk/blend_position", direction)
		self.animation_state.travel("Walk")

func animation_finished():
	_set_is_walking(false)
	animation_state.travel("Idle")
	
func choice_menu(value):
	battle_menu.visible = value
	battle_menu.grab_click_focus()

func attack_range(cell, type = null):
	var att_range : PoolVector2Array
#	att_range.append(cell)
	if type == null:
		for dir in DIRECTIONS:
			att_range.append(cell + dir)	
		return att_range
	elif type == "archer":
		for dir in DIRECTIONS:
			att_range.append(cell + dir*2)
		for diag in DIAGONALS:
			att_range.append(cell+diag)
		return att_range

func get_tile_stats():
	var plus_avoid : int
	var plus_defense : int
	
	var forests = tile_objects.get_used_cells_by_id(1)
	for k in tile_objects.get_used_cells_by_id(2):
		forests.append(k)
	
	var trees = tile_objects.get_used_cells_by_id(0)
	
	var plains = tile_background.get_used_cells_by_id(0)
	var rivers = tile_background.get_used_cells_by_id(1)
	for i in forests:
		plains.erase(i)
	for j in trees:
		plains.erase(j)
	
	if self.cell in forests:
		plus_defense = tile_attributes["Forest"][0]
		plus_avoid = tile_attributes["Forest"][1]
	elif self.cell in plains:
		plus_defense = tile_attributes["Plain"][0]
		plus_avoid = tile_attributes["Plain"][1]
	else:
		plus_defense = tile_attributes["Plain"][0]
		plus_avoid = tile_attributes["Plain"][1]

	return [plus_defense, plus_avoid]
		

func effect_triggered(effect = null):
	#Triggers an effect from an item or spell
	match effect:
		"Health Potion":
			status_bar.tween_health_status(40)
			
			if self.max_health > health + 40:
				self.health += 40
			else:
				self.health = self.max_health
			self.effects.visible = true
			self.effects.play("Health Potion")
			self.effects.playing = true
			yield(get_tree().create_timer(1.2), "timeout")
			self.effects.playing = false
			self.effects.visible = false
			
		"Level Up":
			self.effects.visible = true
			self.effects.play("Level Up")
			self.effects.playing = true
			yield(get_tree().create_timer(1.2), "timeout")
			self.effects.playing = false
			self.effects.visible = false
			


			
			
			


func _on_Wait_pressed():
	battle_menu.visible = false
	#Receives the signal from the Wait button
	#Connects the signal to GameTest where the cursor will be then activated
	connect('wait_selected', get_parent(), 'enemy_wait_selected')
	emit_signal("wait_selected")
	var tile_stats = get_tile_stats()




func _on_Attack_pressed():
	battle_menu.visible = false
	#randomization of attack damage
	connect('attack_selected', get_parent(), "enemy_attack_selected")
	emit_signal("attack_selected")



func _on_Item_pressed():
	battle_menu.visible = false
	item_menu.item_list()
	connect('item_selected', get_parent(), "enemy_item_selected")
	emit_signal("item_selected")
	pass # Replace with function body.


func _on_Item_Menu_item_connect(type, name, position):
	pass
	

func _on_Item_Menu_item_action(staged_item, staged_position, action_type):
	emit_signal("item_engaged", staged_item, staged_position, action_type)
	pass # Replace with function body.
