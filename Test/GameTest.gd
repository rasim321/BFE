extends Node2D

export var grid: Resource = preload("res://World/Grid.tres")

onready var _unit_overlay: UnitOverlay = $UnitOverlay
onready var cursor = $Cursor

#Navigation
onready var astar_path = preload("res://Test/Astar_Path.gd").new()
onready var unit_stats = $HUD/Unit_Stats
var path_begin : Vector2

#Turn Phase
onready var turn_phase = $HUD/Turn_Phase
onready var tween = $Tween

#Tiles
onready var Background = $Background
onready var Objects = $Objects

#Experience
onready var exp_stats = $HUD/Exp_Stats
onready var level_up_stats = $HUD/Level_Up

#Items
onready var items = $"/root/GlobalInventory".inventory 
onready var items_func = $"/root/GlobalInventory" 

# Units
var _units:= {}
var _all_playable_units := {}
var _all_enemy_units := {}
var _playable_units := {}
var _playable_enemies := {}
var _active_unit: Enemy


# Flags
var selection_active = false
var attack_active = false
var player_choice = false
var player_phase = true
var comp_stats_active = false

# An array for all the obstacles
var _obstacles = PoolVector2Array()
var _walkable_cells = PoolVector2Array()
var _attack_cells = PoolVector2Array()

# For the flood_fill algorithm
const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
const DIAGONALS = [Vector2(1,1), Vector2(1,-1), Vector2(-1,1), Vector2(-1,-1)]

#Check for turns:
var turn_taken = []

#signals
signal player_turn_start


#for now in function,
#we add the obstacles to the _obstacles list
func _ready():
	_reinitialize()
	_refresh_playable()
	
#	_refresh_enemies()

	#Connect the item signals from all units
	for child in get_children():
		var unit := child as Enemy
		if unit:
			unit.connect("item_engaged", self, "_on_Item_engaged")



	#Get all the obstacles in the map
	_obstacles = []
	#Append water tiles to _obstacles
	for water_tiles in Background.get_used_cells_by_id(1):
		_obstacles.append(water_tiles)
	for water_cliff_tiles in Background.get_used_cells_by_id(2):
		_obstacles.append(water_cliff_tiles)
	#Append cliff tiles to _obstacles
	for cliff_tiles in Objects.get_used_cells_by_id(3):
		_obstacles.append(cliff_tiles)
	#Append tree tiles to _obstacles
	for tree_tiles in Objects.get_used_cells_by_id(2):
		_obstacles.append(tree_tiles)
	
	#Set up astar path for navigation
	astar_path.used_cells = _walkable_cells
	add_child(astar_path)
	
#	_unit_path.initialize(_walkable_cells)


func _reinitialize() -> void:
	_units.clear()
	
	for child in get_children():
		var unit := child as Enemy
		if not unit:
			continue
			
	
		_units[unit.cell] = unit	
		
		if unit.player_char == true:
			_all_playable_units[unit.cell] = unit
		else:
			_all_enemy_units[unit.cell] = unit
	print(_units)

func _refresh_playable() -> void:
	_playable_units.clear()
	
	for child in get_children():
		var p_unit := child as Enemy
		if not p_unit:
			continue
		if p_unit.playable == false:
			continue
		if turn_taken.has(p_unit):
			continue
		
		toggle_player_normal(p_unit)
		_playable_units[p_unit.cell] = p_unit
		
func _refresh_enemies() -> void:
	_playable_enemies.clear()
	for child in get_children():
		var e_unit := child as Enemy
		if not e_unit:
			continue
		if e_unit.playable == true:
			continue
		if turn_taken.has(e_unit):
			continue
		
		toggle_player_normal(e_unit)
		_playable_enemies[e_unit.cell] = e_unit

#we process the drawing of the movement_grid here as well as removing the grid
func _process(delta):
	
#	movement grid
	if selection_active == true:
		_unit_overlay.visible = true
		update()
		# Here the first argument is array of cells and second is tile number 
		# to show the move range
		_unit_overlay.draw(_walkable_cells,0)
	
#	attack grid
	if attack_active == true:
		selection_active = false
		_unit_overlay.visible = true
		update()
		_unit_overlay.draw(_attack_cells,1)
	
#	item use grid
	if item_use_active == true and item_action_type == "use":
		selection_active = false
		_unit_overlay.visible = true
		update()
		_unit_overlay.draw(_item_use_cells,1)

	
	#Player turn ends
	if len(turn_taken) == len(_playable_units) and player_phase == true:
		#immediately switch the player phase so it doesn't keep running
		player_phase = false
		#refresh the enemies before turn taken so that it doesn't trigger the
#		enemy turn ends phase
		_refresh_enemies()
		turn_taken.clear()
		
		
		#set a timer
		yield(get_tree().create_timer(2), "timeout")
		
		_refresh_playable()
		#turn the phase
		phase_turner()		
		
		#trigger the enemy action
		enemy_action()
		
	#Enemy turn ends
	if len(turn_taken) == len(_playable_enemies) and player_phase == false:
		#immediately switch the player phase so it doesn't keep running
		player_phase = true
		
		#refresh the player first before clearing the turn_taken list
		_refresh_playable()
		turn_taken.clear()
		
		
		#set a timer
		yield(get_tree().create_timer(2), "timeout")
		
		_refresh_enemies()
		#turn the phase
		phase_turner()
		

		
	
	

func enemy_action():
	print("Enemy Turn Activated")
	yield(get_tree().create_timer(1.2), "timeout")
	var enemy_speeds : Array
	var min_speed = 10000
	
	#We need a way to find the enemy character with the highest speed to go first
#
#	For units in playable_enemies, we check if the move_speed value is lower than
#	the minimum speed currently

#	If it is slower, then we send it to the back with push_back
#	If not we send it to the front with push_front
#
#	This way, we have an ordered list of fastest to slowest enemies.

	for unit in _playable_enemies.values():
		
		if unit.move_speed < min_speed:
			min_speed = unit.move_speed
			enemy_speeds.push_back(unit)
#			turn_taken.append(unit)
		else:
			enemy_speeds.push_front(unit)
#			turn_taken.append(unit)
	
#	Todo:
#	Make the get_killable_cells inherent to the enemy unit type
#	So that the archer and fighters can instantly get the kill cells
	
	for m_unit in enemy_speeds:
		
		# see if enemies are in the notice range
		var _notice_range = flood_fill(m_unit.cell, m_unit.notice_range)
		# get attack range which is walk_range plus 1
		_walkable_cells = get_walkable_cells(m_unit, 1)
		# where we store the cells from which to attack
		var kill_dict = generate_kill_dict(m_unit, m_unit.war_class)
		
#		for killable in _units.keys():
#			var _killable_cells = []
#			if _walkable_cells.has(killable):
#				if _units[killable].playable == true:
#					for cell in flood_fill(_units[killable].cell,1):
#						if cell in get_walkable_cells(m_unit) and cell != _units[killable].cell:
#							_killable_cells.append(cell)
#					kill_dict[_units[killable]] = _killable_cells
					
		var target := []
		
		if len(kill_dict) != 0:
			target = get_random_target_and_position(kill_dict)
			
			#Let's check if the kill target does not have an approachable tile
			#if not, we attack, if it can't be reached, we end the turn
			if target[1] == Vector2(-99,-99):
				turn_finished(m_unit)
			else:
		#		Move the enemy unit close to the randomly targetted player
				select_enemy_unit(m_unit.cell)
				_move_enemy_unit(target[1])
				yield(get_tree().create_timer(1), "timeout")
				cursor.position = Vector2((target[0].position.x - (grid.cell_size.x/2)),(target[0].position.y - (grid.cell_size.y/2))) 
				yield(get_tree().create_timer(1), "timeout")
				
				#Finalize Movement
				finalize_movement(astar_path.path[-1])
		#		Fight the Player Unit chosen at random
				#Battle Stats - offender, defender
				$HUD/Battle_Scene.battle_stats(m_unit,target[0])
				#Battle_Start - offender.attack, defender, offender, offender_cell
				$HUD/Battle_Scene.battle_start(m_unit.common_attack,
				 target[0], m_unit)
				yield(get_tree().create_timer(4), "timeout")
		#					#Once attack is successful we finalize the movement
				deselect_player()
				turn_finished(m_unit)
		else:
			var approachable_units = []
			for unit_cell in _units.keys():
				if _units[unit_cell].playable == true:
					if _notice_range.has(unit_cell):
						approachable_units.append(_units[unit_cell])
						
			if len(approachable_units) != 0:
				select_enemy_unit(m_unit.cell)
				_move_enemy_unit(closest_cell_to_move(m_unit, m_unit.move_range,
				 approachable_units[randi() % len(approachable_units)]))
				turn_finished(m_unit)
			else:
				turn_finished(m_unit)



		
func generate_kill_dict(unit, war_class = null):
#	This is the dictionary that will be returned
#	The key is the character that can be attacked, and the value is a list
#	with the cells from which the character can be attacked
	var kill_dict = {}
	
#	match statement takes the class of the character

#   TODO: Figure out a way for kill_dict to still work while obstructing
#	enemy movement when confronted with player cells.

	match war_class:
		#For general one cell attack units:
		"swordsman", "axeman", "spearman":
			#We get the unit's move cells plus one offset for the attack range
			_walkable_cells = get_walkable_cells(unit, 1)
			#where we store the cells from which to attack
			
			#For each unit in the field
			for killable in _units.keys():
				var _killable_cells = []
				#we check if the unit is standing in the attack range
				if _walkable_cells.has(killable):
					#and if the unit is a player unit
					if _units[killable].playable == true:
						#if true, for each cell surrounding that unit 
						for cell in flood_fill(_units[killable].cell,1):
							#if the cell is in the attack range and not the unit's own cell
							#Turn on for_enemy in flood_fill so that enemies can't surpass players
							if cell in flood_fill(unit.cell, unit.move_range, true) and cell != _units[killable].cell:
								#we add it to the _killable_cells list
								_killable_cells.append(cell)
						#the key value pair is then formed
						kill_dict[_units[killable]] = _killable_cells
					
		#For ranged characters
		"archer":
			#we get the normal move range
			_walkable_cells = get_walkable_cells(unit)
			#for each unit
			for killable in _units.keys():
				#if it's a player character
				if _units[killable].playable == true:
					var _killable_cells = []
					#we get the range of vulnerability of the player character
					var vulnerable_range = _units[killable].attack_range(killable, "archer")
					#for each cell in the vulnerable_range
					for cell in vulnerable_range:
						#if the archer can walk there
						if cell in _walkable_cells:
							#we add it to the _killable_cells list
							_killable_cells.append(cell)
					#create the key value pair
					kill_dict[_units[killable]] = _killable_cells
	
	return kill_dict
	


func _input(event):
	
	"""
	List all flags
#	selection_active -> if player is selected
#	attack_active -> if attack is active
#	player_choice -> if player choice menu is open
#	item_use_active -> if player item usage is active
	"""
	
	#If selection is inactive and player clicks:
	#If units has the cell the cursor clicked
	#If attack mode is not active
	#Select the player

	if selection_active == false and Input.is_action_just_pressed("ui_accept"):
		if _playable_units.has(cursor.clicked):
			#change made here
			if attack_active == false and player_choice==false and item_use_active==false:
				if not turn_taken.has(cursor.clicked):
					select_player(cursor.clicked)
					yield(get_tree().create_timer(0.2), "timeout")
			
	#Cancel select active
	if selection_active == true and Input.is_action_just_pressed("ui_cancel"):
		deselect_player()
	
	#Move unit when selection active is on
	if selection_active == true:
		if Input.is_action_just_pressed("ui_accept"):
#			_walkable_cells.append(_active_unit.cell)
			if (_walkable_cells as Array).has(cursor.clicked):
				if cursor.clicked != _active_unit.cell:
					_move_active_unit(cursor.clicked)
				else:
					_move_active_unit(_active_unit.cell)
					
	#Move the player back to original position if a player 
	#cancels the move
	if player_choice == true:
		
		
		#Cancelling just item selection
		if attack_active == false and item_selection_active == true and Input.is_action_just_pressed("ui_cancel"):

			_active_unit.item_menu.visible = false
			item_selection_active = false
			_active_unit.battle_menu.visible = true
			
		
		#Cancelling without item_selection or attack selection
		elif item_selection_active == false and attack_active == false and Input.is_action_just_pressed("ui_cancel"):
			_active_unit.position = grid.calculate_map_position(path_begin)
			_active_unit.move_player(grid.calculate_map_position(astar_path.path[-1]),
			grid.calculate_map_position(path_begin), 0.02)
			finalize_movement(path_begin)
		yield(_active_unit, "wait_selected")
					

	#attack unit
	if attack_active == true:
		if Input.is_action_just_pressed("ui_accept"):
			if (_attack_cells as Array).has(cursor.clicked):
				if _units.has(cursor.clicked):
					if _units[cursor.clicked].playable == false:
						
						#Launch the comparison UI screen
						$HUD/Comp_Stats.comp_stats(_units[path_begin], _units[cursor.clicked])
						
						#Turn comp_stats_active flag on
						comp_stats_active = true
						#Turn off attack_active flag
						attack_active = false
						#Create a short lag for the inputs
						yield(get_tree().create_timer(0.2), "timeout")

		#Player can cancel an attack
		if Input.is_action_just_pressed("ui_cancel"):
			deselect_player()
			attack_active = false
			_active_unit.position = grid.calculate_map_position(path_begin)
			_active_unit.move_player(grid.calculate_map_position(astar_path.path[-1]),
			grid.calculate_map_position(path_begin), 0.02)
			finalize_movement(path_begin)
			$HUD/Comp_Stats.hide_comp_stats()
		
	if comp_stats_active == true:
		if Input.is_action_just_pressed("ui_accept"):
			if (_attack_cells as Array).has(cursor.clicked):
				if _units.has(cursor.clicked):
					if _units[cursor.clicked].playable == false:
						
						#keep the offender and defender constant
						var defender = _units[cursor.clicked]
						var offender = _units[path_begin]
						
						#Turn the input process off
						self.set_process_input(false)
						
						#Hide the comparison stats
						$HUD/Comp_Stats.hide_comp_stats()
						
						#Battle Stats - offender, defender
						$HUD/Battle_Scene.battle_stats(offender,defender)

						#Battle_Start - offender.attack, defender, offender
						$HUD/Battle_Scene.battle_start(offender.common_attack,
						 defender, offender)
						
						finalize_movement(astar_path.path[-1])

#						yield(get_tree().create_timer(2), "timeout")
						
						## Handing Exp
						#Connect the add_experience signal
						_active_unit.connect("add_experience", self, "_on_add_experience")
						#Wait for the animation to finish
						
						#If there's going to be a double attack, yield twice for animation
						#finished, if not, yield only once
						if Experience.speed_diff(offender.char_name, defender.char_name):
#							yield(get_tree().create_timer(5), "timeout")
							yield($HUD/Battle_Scene/Offender_Sprite, "animation_finished")
							yield($HUD/Battle_Scene/Offender_Sprite, "animation_finished")
						else:
							yield($HUD/Battle_Scene/Offender_Sprite, "animation_finished")
							
						yield(get_tree().create_timer(0.2), "timeout")

						#We need the current level to see if the character has leveled up
						var cur_level = Experience.experience[_active_unit.char_name]["level"]

						_active_unit.add_experience("attack", defender)

						#Trying to delay the toggle_player_dark for level up
						if Experience.experience[_active_unit.char_name]["level"] > cur_level:
							yield(get_tree().create_timer(2.0), "timeout")

						turn_finished(_active_unit)
						#turn on input process
						self.set_process_input(true)
						#turn off comp_stats_active
						comp_stats_active = false
		
		if Input.is_action_just_pressed("ui_cancel"):
			deselect_player()
			attack_active = false
			_active_unit.position = grid.calculate_map_position(path_begin)
			_active_unit.move_player(grid.calculate_map_position(astar_path.path[-1]),
			grid.calculate_map_position(path_begin), 0.02)
			finalize_movement(path_begin)
			$HUD/Comp_Stats.hide_comp_stats()
			comp_stats_active = false
			
	#Use item
	if item_use_active == true:
		

		# If discard item was clicked
		if item_action_type == "discard":
			# Wait for the discard confirmation signal
			
			#The signal's value from item_menu gets stored in the discard_action variable
			var discard_action = yield(_active_unit.item_menu, "item_discarded")
			#If true, we discard the item using the engage item function
			
			#we need to use double flags here or the code block runs multiple times
			
			if discard_action == true and item_use_active == true:
				#turn of item_use_active
				item_use_active = false
				engage_item(_active_unit, _active_unit, staged_item_current,
							staged_position_current, item_action_type)
				_unit_overlay.visible = false
				unit_stats.hide_stats()
				turn_finished(_active_unit)
			
			#Once again, code block runs multiple times here if double flags not used
			elif discard_action == false and item_use_active == true:

				item_use_active = false
				_active_unit.item_menu.visible = false
				_active_unit.battle_menu.visible = true
				
			#Return discard action to false	after loop finishes
			discard_action = false
					
		
		if Input.is_action_just_pressed("ui_accept"):
			#If use item was clicked
			if item_action_type == "use":
				if (_item_use_cells as Array).has(cursor.clicked):
					if _all_playable_units.has(cursor.clicked):
						if _all_playable_units[cursor.clicked].player_char == true:
							
							#Engage item
							engage_item(_active_unit, _all_playable_units[cursor.clicked], staged_item_current,
							staged_position_current, item_action_type)
							
							
							#Cancel the item range visual
							_unit_overlay.visible = false
							
							yield(get_tree().create_timer(1.3), "timeout")
							unit_stats.hide_stats()
							turn_finished(_active_unit)
							
			
			
		#Cancelling the item use selection
		if Input.is_action_just_pressed("ui_cancel"):
			
				#empty the use cells
				_item_use_cells.empty()
				#empty all the item variables to default values
				staged_item_current = ""
				staged_position_current = 0
				item_action_type = ""
				#change the state of the flags to allow other options
				_unit_overlay.visible = false
				_active_unit.item_menu.visible = false
				_active_unit.battle_menu.visible = true
				item_use_active = false
				selection_active = false
				player_choice = true
				item_selection_active = false




func engage_item(user, used_on, item, item_position, action_type):
	
	

	match action_type:
		"use":

			match item:
				"Health Potion":
					used_on.effect_triggered(item)
					item_use_active = false
					items_func.item_setter(user.char_name, item, item_position, -1)

					#Refresh the item list in the UI
					user.get_node("Battle_Node/Item_Menu").item_refresh()
					
		"discard":
			item_use_active = false
			item_selection_active = false
			items[user.char_name]["items"].pop_at(item_position)
			items[user.char_name]["quantity"].pop_at(item_position)
			user.get_node("Battle_Node/Item_Menu").item_refresh()


func flood_fill(cell, max_distance, for_enemy = false):
	
	# for_enemy is used selectively when the enemy is moving 
	
	#these are all the tiles that will be in the moveable space
	var move_array = []
	
	#the stack will gather every cell we are investigating to put into move_array
	var stack = [cell]
	
	while not stack.empty():
		var current = stack.pop_back()
		
		if current in move_array:
			continue
		if not grid.is_within_bounds(current):
			continue
		
		# If the current cell is in _units
		# Check if the unit is a player or an enemy
		# and then exclude the opposite team of cells
		if _units.has(current):
			if _units[cell].playable == true:
				if _units[current].playable == false:
					continue
			if for_enemy == true:
				if _units[cell].playable == false:
					if _units[current].playable == true:
						continue
#			else:
#				if _units[current].playable == true:
#					continue

#		
		
		var difference = (current - cell).abs()
		var distance = int(difference.x + difference.y)
		if distance > max_distance:
			continue
		
		move_array.append(current)
		
		for direction in DIRECTIONS:
			var coordinates: Vector2 = current + direction
			
			if is_occupied(coordinates):
				continue
			if coordinates in move_array:
				continue

			# This is where we extend the stack.
			stack.append(coordinates)
	
	return move_array
		

func select_player(cell):
	if not _units.has(cell):
		return
	#selection_active = true happens in here:
	
	_active_unit = _units[cell]
	_walkable_cells = get_walkable_cells(_active_unit)
	_active_unit.set_is_selected(true)
	
	##Navigation
	path_begin = cell
	selection_active = true
	
	# Show unit stats
	unit_stats.show_stats()
	unit_stats.update_stats(_active_unit.char_name, _active_unit.health,
	_active_unit.max_health, _active_unit.war_class)
	
	
	
func _clear_active_unit() -> void:
	_active_unit = null
	_walkable_cells.clear()
	
func _move_active_unit(new_cell: Vector2) -> void:
	
	var temp_units = _units
	temp_units.erase(_active_unit.cell)
	## DISABLED FOR NOW TO TEST##
	if is_occupied(new_cell) or not new_cell in _walkable_cells or temp_units.has(new_cell):
		return
	


	print("This is the active unit:", _active_unit)
	deselect_player()
	
	## Navigation
	#This gives us the path to the destination
	astar_path.used_cells = _walkable_cells
	astar_path._add_points()
	astar_path._connect_points()
	astar_path._get_path(path_begin, new_cell)
	
	_active_unit._set_is_walking(true)
	
	## Movement
	#dir holds the last position that the unit was in to engineer direction
	var dir = path_begin
	
	#For each next step in the path
	for p in astar_path.path:
		#Let's get thedirection to rotate the animation accordingly
		_active_unit.direction = _active_unit.position.direction_to(grid.calculate_map_position(p))
#		_active_unit.position = grid.calculate_map_position(p)
		#Use the move player function to tween
		_active_unit.move_player(grid.calculate_map_position(dir),
		grid.calculate_map_position(p), 0.2)
		#Have a little cooldown for the animation
		yield(get_tree().create_timer(0.18), "timeout")
		#set the "dir" variable to this step
		dir = p
	_active_unit.choice_menu(true)
	player_choice = true
	
	
func finalize_movement(new_cell):
	
	attack_active = false
	_unit_overlay.visible = false

	_active_unit.animation_finished()
	_active_unit.battle_menu.visible = false
	
	_units.clear()
	_units[new_cell] = _active_unit
	_active_unit.cell = new_cell
	
	#This deacticvates the cursor
	cursor.cursor_status(false)
	
	player_choice = false
	
	#Make the player greyscale and refuse selection
	
	_reinitialize()

func select_enemy_unit(cell : Vector2)-> void:
	if not _units.has(cell):
		return
	#selection_active = true happens in here:
	
	_active_unit = _units[cell]
	_walkable_cells = get_walkable_cells(_active_unit,1)
	_active_unit.set_is_selected(true)
	
	##Navigation
	path_begin = cell
	selection_active = true
	
	# Show unit stats
	unit_stats.show_stats()
	unit_stats.update_stats(_active_unit.char_name, _active_unit.health,
	_active_unit.max_health, _active_unit.war_class)
	

func _move_enemy_unit(new_cell: Vector2) -> void:
	if is_occupied(new_cell) or not new_cell in _walkable_cells or _units.has(new_cell):
		print("enemy unit can't move there")
		return
	deselect_player()
	astar_path.used_cells = _walkable_cells
	astar_path._add_points()
	astar_path._connect_points()
	astar_path._get_path(path_begin, new_cell)
	
	_active_unit._set_is_walking(true)
	
	var dir = path_begin
	
	#For each next step in the path
	for p in astar_path.path:
		#Let's get thedirection to rotate the animation accordingly
		_active_unit.direction = _active_unit.position.direction_to(grid.calculate_map_position(p))
#		_active_unit.position = grid.calculate_map_position(p)
		#Use the move player function to tween
		_active_unit.move_player(grid.calculate_map_position(dir),
		grid.calculate_map_position(p), 0.2)
		#Have a little cooldown for the animation
		yield(get_tree().create_timer(0.18), "timeout")
		#set the "dir" variable to this step
		dir = p
		
	_unit_overlay.visible = false

	_active_unit.animation_finished()
	_active_unit.battle_menu.visible = false
	
	_units.clear()
	_units[new_cell] = _active_unit
	_active_unit.cell = new_cell
	
	#This deacticvates the cursor
	cursor.cursor_status(false)
	
	player_choice = false
	
	_reinitialize()
	
	
	
func toggle_player_dark(unit):
	if unit in turn_taken:
		unit.modulate = Color(0.299, 0.299, 0.114)

func toggle_player_normal(unit):
	unit.modulate = Color(1,1,1)
	
func turn_finished(unit):
	turn_taken.append(unit)
	_active_unit.item_menu.visible = false
	toggle_player_dark(unit)
	#This is a new edition, might have to remove
	_reinitialize()


func phase_turner():
	turn_phase.visible = true
	turn_phase.get_node("Turn_Background").modulate = Color(1,1,1,0)
	if player_phase == true:
		turn_phase.get_node("Turn_Background/Turn_Text").text = "Player Phase"
	else:
		turn_phase.get_node("Turn_Background/Turn_Text").text = "Enemy Phase"
	turn_phase.phase_in()
	yield(get_tree().create_timer(1), "timeout")
	turn_phase.visible = false
	


func enemy_wait_selected():
	cursor.cursor_status(true)
	_active_unit.animation_finished()
	print("wait message received")
	finalize_movement(astar_path.path[-1])
	turn_finished(_active_unit)
	pass
	
func enemy_attack_selected(type = null):
	finalize_movement(_active_unit.cell)
	deselect_player()
	_active_unit.animation_finished()
	cursor.cursor_status(false)
	attack_active = true
	_attack_cells = _active_unit.attack_range(astar_path.path[-1], type)
#	print("attack message received")
	pass
	
func _on_Level_Up(unit):
	level_up_stats.level_up(unit)
	
	

## Helper Functions ##

# Checks whether the grid is occupied by some obstacle
# will have to fill in the tile map objects to this list
func is_occupied(cell):
	return true if (_obstacles as Array).has(cell) else false
		
		
#Gives out all the walkable grids for a unit
func get_walkable_cells(unit: Enemy, offset = 0) -> Array:
	return flood_fill(unit.cell, unit.move_range + offset)

## Signals ##

func deselect_player():
	print("player deselected")
	_active_unit.animation_finished()
	_active_unit.set_is_selected(false)
	_active_unit.choice_menu(false)
	_unit_overlay.clear()
	selection_active = false
	#Hide unit stats
	unit_stats.hide_stats()
	
func get_random_target_and_position(dict):
	var a = dict.keys()
	#get a random target to attack
	a = a[randi() % a.size()]
	
	#empty array b to store the attackable_cells
	var b = []
	#Unless there are no attackable_cells
	if not dict[a].empty():
		#check for obstacles and units
		for i in dict[a]:
			if (_units.has(i) or (_obstacles as Array).has(i)):
				continue
			else:
				#if no obstacles or units, append
				b.append(i)
	#no attacklable_cells so b is empty
	else:
		b = []
			
#	if b is not empty
	if not b.empty():
		#get a random position around the target
		b = b[randi() % b.size()]
		return [a, b]
	#if b is empty
	else:
		#remove that unit from the dictionary
		dict.erase(a)
		#check if dictionary is empty
		if dict.empty():
			#if empty, return -99 vectors which GameTest knows to read as empty
			return [Vector2(-99,-99), Vector2(-99,-99)]
		#if not empty
		else:
			#recursion to find another unit to attack
			return get_random_target_and_position(dict)
		
	
func closest_cell_to_move(enemy_unit, move_range, player_unit):
	# this is the notice range for the enemy unit
	var notice_cells = flood_fill(enemy_unit.cell, enemy_unit.notice_range)
	
	# find all the path to the player unit
	astar_path.used_cells = notice_cells
	astar_path._add_points()
	astar_path._connect_points()
	astar_path._get_path(enemy_unit.cell, player_unit.cell)
	
	# store the path
	var total_path = astar_path.path
	
	# get the moveable range
	var moveable_cells = flood_fill(enemy_unit.cell, enemy_unit.move_range, true)
	
	# distance 
	var max_distance := 0
	
	# the closest cell that the enemy can get to
	var closest_cell : Vector2

	# for each cell in the path
	for path_cell in total_path:
		# check if the cell is in the moveable range
		if path_cell in moveable_cells:
			# and calculate the distance
			var distance = path_cell.distance_to(enemy_unit.cell)

			# if the distance is greater than maximum
			if distance > max_distance:
				# store it as the new max
				max_distance = distance
				# store that cell as that closest to the player unit
				closest_cell = path_cell
	
#	after all the cells are checked, return the closest_cell
	return closest_cell

var item_selection_active = false

func enemy_item_selected():
	item_selection_active = true
	
	
var item_use_active = false
var _item_use_cells = []
var staged_item_current : String # Health Potion
var staged_position_current : int # 0
var item_action_type : String # "use"

func _on_Item_engaged(staged_item, staged_position, action_type):
	
	item_use_active = true
	_item_use_cells = _active_unit.attack_range(astar_path.path[-1])
	_item_use_cells.append(astar_path.path[-1])
	staged_item_current = staged_item
	staged_position_current = staged_position
	item_action_type = action_type
	finalize_movement(astar_path.path[-1])

func _on_add_experience(unit, amount):
	exp_stats.update_exp(unit, amount)
	
## Notes:

# player choice = player choice is when the choice menu is active for the player
# It is activated in move_player function and deactivated in finalize_movement function
	
# turn_finished(unit): Turn finished is called twice in the code. Once after 
# receiving the signal wait selected, and another time after the battle animations
#have played in the input function


