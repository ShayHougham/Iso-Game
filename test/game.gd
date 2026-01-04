extends Node3D

@export var unit_scene: PackedScene
@onready var cam: Camera3D = $CameraRig/Camera3D
@onready var board := $Board
@onready var units_root := $Units
var hovered_tile: Tile = null
var selected_tile: Tile = null

func _ready() -> void:
	spawn_unit(Vector2i(2, 2))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var tile := pick_tile(event.position)
		select_tile(tile)

func spawn_unit(grid_pos: Vector2i) -> void:
	var unit := unit_scene.instantiate()
	units_root.add_child(unit)

	var world_pos = board.grid_to_world_center(grid_pos)
	world_pos.y += 1 # lift above tile
	world_pos.x += 0.5
	world_pos.z += 0.5
	
	unit.global_position = world_pos

func pick_tile(screen_pos: Vector2) -> Tile:
	# Convert mouse position on screen into a ray in 3D space
	var origin := cam.project_ray_origin(screen_pos)
	var dir := cam.project_ray_normal(screen_pos)
	var to := origin + dir * 1000.0

	# Ask the physics world what we hit
	var space := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(origin, to)
	var hit := space.intersect_ray(query)

	if hit.is_empty():
		return null

	# hit["collider"] will be the StaticBody3D we clicked
	var collider: Object = hit["collider"]
	if collider and collider.get_parent() is Tile:
		return collider.get_parent()
		
	return null

func _process(_delta: float) -> void:
	update_hover()

func update_hover() -> void:
	var mouse_pos := get_viewport().get_mouse_position()
	var tile := pick_tile(mouse_pos)
	
	if tile == hovered_tile:
		return
		
	if hovered_tile:
		hovered_tile.set_hovered(false)
		
	hovered_tile = tile
	
	if hovered_tile:
		hovered_tile.set_hovered(true)
		

func select_tile(tile: Tile) -> void:
	if selected_tile:
		selected_tile.set_selected(false)

	selected_tile = tile

	if selected_tile:
		selected_tile.set_selected(true)
		print("Selected tile:", selected_tile.grid_pos)
