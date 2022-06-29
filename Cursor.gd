extends Node2D

#onready var grid_size = Vector2(get_viewport_rect().size.x, get_viewport_rect().size.y)
onready var grid_size = Vector2(get_viewport_rect().size.x, get_viewport_rect().size.y)
export var grid: Resource = preload("res://World/Grid.tres")
export var debug_mode = true

onready var tile_stats = get_parent().get_node("HUD/Tile_Stats")
onready var tile_background = get_parent().get_node("Background")
onready var tile_objects = get_parent().get_node("Objects")
onready var tile_attributes = $"/root/TileAttributes".tile_attributes

var cell_size = 32
var coord = Vector2(0,0)
var clicked = Vector2(0,0)

#Updating Tile Stats
onready var unit_stats = get_parent().get_node("HUD/Unit_Stats")
onready var _units_cursor = get_parent()._units

func get_tile_hud(coord):
	#Forest tiles
	var forests = tile_objects.get_used_cells_by_id(1)
	
	#Fort tiles
	var forts = tile_objects.get_used_cells_by_id(8)
	
	var trees = tile_objects.get_used_cells_by_id(2)
	var cliffs = tile_objects.get_used_cells_by_id(3)
	
	var plains = tile_background.get_used_cells_by_id(0)
	var waters = tile_background.get_used_cells_by_id(1)
	for water_tiles in tile_background.get_used_cells_by_id(2):
		waters.append(water_tiles)
	
	var erase_from_plains = [forests, forts, trees, cliffs ]
	
	#remove the forests, trees, and cliffs from plains
	for i in erase_from_plains:
		for j in i:
			plains.erase(j)
	
	
	if coord in forests:
		tile_stats.get_node("Tile_HUD/Tile_Type").text = "Forest"
		tile_stats.get_node("Tile_HUD/Avoid_Number").text = str(tile_attributes["Forest"][1])
		tile_stats.get_node("Tile_HUD/Defense_Number").text = str(tile_attributes["Forest"][0])
	elif coord in waters:
		tile_stats.get_node("Tile_HUD/Tile_Type").text = "Water"
		tile_stats.get_node("Tile_HUD/Avoid_Number").text = "-"
		tile_stats.get_node("Tile_HUD/Defense_Number").text = "-"
	elif coord in plains:
		tile_stats.get_node("Tile_HUD/Tile_Type").text = "Plain"
		tile_stats.get_node("Tile_HUD/Avoid_Number").text = str(tile_attributes["Plain"][1])
		tile_stats.get_node("Tile_HUD/Defense_Number").text = str(tile_attributes["Plain"][0])
	elif coord in trees:
		tile_stats.get_node("Tile_HUD/Tile_Type").text = "Tree"
		tile_stats.get_node("Tile_HUD/Avoid_Number").text = "-"
		tile_stats.get_node("Tile_HUD/Defense_Number").text = "-"
	elif coord in cliffs:
		tile_stats.get_node("Tile_HUD/Tile_Type").text = "Cliff"
		tile_stats.get_node("Tile_HUD/Avoid_Number").text = "-"
		tile_stats.get_node("Tile_HUD/Defense_Number").text = "-"
	elif coord in forts:
		tile_stats.get_node("Tile_HUD/Tile_Type").text = "Fort"
		tile_stats.get_node("Tile_HUD/Avoid_Number").text = str(tile_attributes["Fort"][1])
		tile_stats.get_node("Tile_HUD/Defense_Number").text = str(tile_attributes["Fort"][0])
	else:
		tile_stats.get_node("Tile_HUD/Tile_Type").text = "Unknown"
		tile_stats.get_node("Tile_HUD/Avoid_Number").text = "-"
		tile_stats.get_node("Tile_HUD/Defense_Number").text = "-"

		
func get_unit_hud(coord):
	
	if coord in _units_cursor:
		if is_instance_valid(_units_cursor[coord]):
		
#			print("ALL ENEMY UNITS", _all_enemy_units_cursor)
			unit_stats.show_stats()
			unit_stats.update_stats(_units_cursor[coord].char_name,
			_units_cursor[coord].health, _units_cursor[coord].max_health,
			_units_cursor[coord].war_class)
		
	else:
		unit_stats.hide_stats()

func _ready():
	#makes sure we are processing inputs
	set_process_input(true)

	
	
func coord_debug():

	get_node("coord").clear()
	get_node("coord").push_color(Color(232,25,25))
	get_node("coord").push_underline()
#	get_node("coord").set_position(Vector2(coord.x*cell_size, coord.y*cell_size))
	get_node("coord").set_global_position(get_global_mouse_position()+Vector2(16,32))
	get_node("coord").add_text("coord = " + str(coord))
	get_node("coord").pop()
	
func _input(event):
	
	if (event is InputEventMouseMotion):
		
#		#This allows for snap to grid cursor movement
		self.position = (get_global_mouse_position()/cell_size).floor()*cell_size
#		coord = Vector2(int((get_global_mouse_position().x)/cell_size),int((get_global_mouse_position().y)/cell_size))
		coord = (get_global_mouse_position()/cell_size).floor()
		#Tile Stats on the bottom left corner
		get_tile_hud(coord)
		get_unit_hud(coord)
			
	#Only if debug mode is on do the cursor coordinates show up:
	if debug_mode == true:
		coord_debug()
		
	if event.is_action_pressed("ui_accept"):
#		or event.is_action_pressed("click")
#		print("cell clicked on:", coord)
		clicked = coord
		
	
		
			
func _draw():
	pass
#	for x in range(0, grid_size.x, cell_size):
#		for y in range(0, grid_size.y, cell_size):
#			draw_line(Vector2(x,y), Vector2(x, y+cell_size), Color(0.2,0.1,0), 1)
#			draw_line(Vector2(x,y), Vector2(x+cell_size, y), Color(0.2,0.1,0), 1)	

func cursor_status(value):
	set_process(value)
