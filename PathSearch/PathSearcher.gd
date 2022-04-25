class_name PathSearcher
extends Reference

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

var _grid = Resource

var _astar := AStar2D.new()

func _init(grid, walkable_cells):
	
	_grid = grid
	var cell_mappings = {}
	for cell in walkable_cells:
		cell_mappings[cell] = _grid.as_index(cell)
		
	_add_and_connect_points(cell_mappings)

func _add_and_connect_points(cell_mappings : Dictionary):
	for point in cell_mappings:
		#AStar2D takes the id first and then the Vector
		_astar.add_point(cell_mappings[point], point)
	for point in cell_mappings:
		for neighbor_index in _find_neighbor_indices(point, cell_mappings):
			_astar.connect_points(cell_mappings[point], neighbor_index)
		
func _find_neighbor_indices(cell, cell_mappings):
	
	var out = []
	for direction in DIRECTIONS:
		var neighbor: Vector2 = cell + direction
		if not cell_mappings.has(neighbor):
			continue
		if not _astar.are_points_connected(cell_mappings[cell], cell_mappings[neighbor]):
			out.push_back(cell_mappings[neighbor])
	
	return out
		
func calculate_point_path(start : Vector2, end : Vector2) -> PoolVector2Array:
	var start_idx = _grid.as_index(start)
	var end_idx = _grid.as_index(end)
	
	if _astar.are_points_connected(start_idx, end_idx):
		return _astar.get_point_path(start_idx, end_idx)
	else:
		return PoolVector2Array()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
