# Board.gd
extends Node3D

@export var width: int = 10
@export var height: int = 10
@export var tile_size: float = 1.0
@export var tile_scene: PackedScene

var tiles := {} # Dictionary: Vector2i -> Tile

func _ready() -> void:
	generate()

func generate() -> void:
	# Clear old tiles if you re-run
	for child in get_children():
		child.queue_free()
	tiles.clear()

	for y in range(height):
		for x in range(width):
			var t := tile_scene.instantiate() as Tile
			add_child(t)

			t.grid_pos = Vector2i(x, y)

			# Grid -> world conversion (simple, square grid)
			t.position = Vector3(x * tile_size, 0.0, y * tile_size)

			tiles[t.grid_pos] = t

func get_tile(grid: Vector2i) -> Tile:
	return tiles.get(grid, null)

func grid_to_world_center(p: Vector2i) -> Vector3:
	return Vector3(
		(p.x + 0.5) * tile_size,
		0.0,
		(p.y + 0.5) * tile_size
	)
