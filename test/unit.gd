extends Node3D
class_name Unit

var grid_pos: Vector2i

@onready var sprite := $AnimatedSprite3D

func _ready() -> void:
	sprite.play("Idle")
