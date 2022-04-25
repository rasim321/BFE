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

func get_tile_hud(coord):
	var forests = tile_objects.get_used_cells_by_id(1)
	for k in tile_objects.get_used_cells_by_id(2):
		forests.append(k)
	
	var trees = tile_objects.get_used_cells_by_id(0)
	
	var plains = tile_background.get_used_cells_by_id(0)
	var waters = tile_background.get_used_cells_by_id(1)
	
	for i in forests:
		plains.erase(i)
	for j in trees:
		plains.erase(j)
	
	if coord in forests:
		tile_stats.get_node("Tile_HUD/Tile_Type").text = "Forest"
		tile_stats.get_node("Tile_HUD/Avoid_Number").text = str(tile_attributes["Forest"][1])
		tile_stats.get_node("Tile_HUD/Defense_Number").text = str(tile_attributes["Forest"][0])
	elif coord in waters:
		tile_stats.get_node("Tile_HUD/Tile_Type").text = "River"
		tile_stats.get_node("Tile_HUD/Avoid_Number").text = str(tile_attributes["River"][1])
		tile_stats.get_node("Tile_HUD/Defense_Number").text = str(tile_attributes["River"][0])
	elif coord in plains:
		tile_stats.get_node("Tile_HUD/Tile_Type").text = "Plain"
		tile_stats.get_node("Tile_HUD/Avoid_Number").text = str(tile_attributes["Plain"][1])
		tile_stats.get_node("Tile_HUD/Defense_Number").text = str(tile_attributes["Plain"][0])
	elif coord in trees:
		tile_stats.get_node("Tile_HUD/Tile_Type").text = "Tree"
		tile_stats.get_node("Tile_HUD/Avoid_Number").text = "-"
		tile_stats.get_node("Tile_HUD/Defense_Number").text = "-"
	else:
		tile_stats.get_node("Tile_HUD/Tile_Type").text = "Unknown"
		tile_stats.get_node("Tile_HUD/Avoid_Number").text = "-"
		tile_stats.get_node("Tile_HUD/Defense_Number").text = "-"
		

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
			
	#Only if debug mode is on do the cursor coordinates show up:
	if debug_mode == true:
		coord_debug()
		
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("click"):
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
