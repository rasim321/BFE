
class_name Grid
extends Resource

#the size of the grid in columns and rows
export var size := Vector2(20,20)

#the size of each cell in pixels
export var cell_size := Vector2(32,32)

#to find the center of the cell where to place the characters
var _half_cell_size = cell_size / 2

# Returns the position of a cell's center in pixels.
# We'll place units and have them move through cells using this function.
func calculate_map_position(grid_position : Vector2) -> Vector2:
	return grid_position * cell_size + _half_cell_size
	
# Get the grid position from the map position
func calculate_grid_position(map_position : Vector2) -> Vector2:
	return (map_position/cell_size).floor()

# Checks whether the cell coordinates are within the bounds of the map
func is_within_bounds(cell_coordinates: Vector2) -> bool:
	var out:= cell_coordinates.x > 0 and cell_coordinates.x <= size.x
	return out and cell_coordinates.y > 0 and cell_coordinates.y <= size.y
	
func clamp(grid_position: Vector2) -> Vector2:
	var out := grid_position
	out.x = clamp(out.x, 0, size.x - 1.0)
	out.y = clamp(out.y, 0, size.y - 1.0)
	return out
	
func as_index(cell: Vector2) -> int:
	return int(cell.x + size.x * cell.y)


	

	
