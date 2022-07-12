extends TileMap
class_name Astar_Path

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

onready var astar = AStar2D.new()
#onready var gametest = get_parent()
#onready var enemy = get_node("Enemy")
var used_cells : PoolVector2Array
var start : Vector2
var end : Vector2
#onready var used_cells = PoolVector2Array([[6,6],[6,7],[6,8]])

export var grid: Resource = preload("res://World/Grid.tres")

var path : PoolVector2Array


#func initialize(used_cells):
#	used_cells = used_cells
#	_add_points()
#	_connect_points()

func _ready():
	_add_points()
	_connect_points()

func _add_points():
	for point in used_cells:
		if get_parent().player_phase == true:
			if get_parent()._all_enemy_units.has(point):
				continue
		else:
			if get_parent()._all_playable_units.has(point):
				continue
				
		astar.add_point(grid.as_index(point), point, 1.0)
	
func _connect_points():
	for cell in used_cells:
		for dir in DIRECTIONS:
			var next_cell = cell + dir
			if (used_cells as Array).has(next_cell):
				astar.connect_points(grid.as_index(cell), grid.as_index(next_cell))
				
func _get_path(start, end):
	
	path = astar.get_point_path(grid.as_index(start), grid.as_index(end))
#	print(path)

#	If the unit wants to remain on the same tile it started from,
#	we allow the path variable to hold that cell. Otherwise, the first
#	the first cell (path_begin) gets removed.
	if start == end:
		pass
	else:
		path.remove(0)
	
	



