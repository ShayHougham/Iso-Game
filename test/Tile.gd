extends Node3D
class_name Tile

var grid_pos: Vector2i

@onready var mesh := $MeshInstance3D

var hovered := false
var selected := false

func _ready() -> void:
	if mesh.material_override:
		mesh.material_override = mesh.material_override.duplicate()
	_update_visual()

func set_hovered(value: bool) -> void:
	hovered = value
	_update_visual()

func set_selected(value: bool) -> void:
	selected = value
	_update_visual()

func _update_visual() -> void:
	# Priority: selected > hovered > normal
	if selected:
		mesh.material_override.albedo_color = Color(0.3, 0.8, 1.0) # blue
	elif hovered:
		mesh.material_override.albedo_color = Color(0.9, 0.9, 0.6) # yellow
	else:
		mesh.material_override.albedo_color = Color(1, 1, 1) # white
