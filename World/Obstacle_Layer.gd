extends TileMap


# Called when the node enters the scene tree for the first time.
func _ready():
	print("Id 0 tiles: ",get_used_cells_by_id(1))
	pass
