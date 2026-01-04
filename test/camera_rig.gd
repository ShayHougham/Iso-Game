extends Node3D

@export var pan_speed: float = 10.0
@export var zoom_speed: float = 3.0
@export var min_zoom: float = 4.0
@export var max_zoom: float = 20.0
@export var rotate_speed: float = 8.0 # bigger = faster smoothing
var target_yaw: float
@export var zoom_smooth: float = 10.0  # higher = snappier, lower = floatier
var target_zoom_dist: float



@onready var cam: Camera3D = $Camera3D

func _ready() -> void:
	target_yaw = rotation.y
	target_zoom_dist = cam.position.length()



func _process(delta: float) -> void:
	_handle_pan(delta)
	_smooth_rotate(delta)
	_smooth_zoom(delta)

func _smooth_zoom(delta: float) -> void:
	var offset: Vector3 = cam.position
	var dist: float = offset.length()
	if dist <= 0.0001:
		return

	var new_dist: float = lerp(dist, target_zoom_dist, zoom_smooth * delta)
	cam.position = offset.normalized() * new_dist


func _smooth_rotate(delta: float) -> void:
	rotation.y = lerp_angle(rotation.y, target_yaw, rotate_speed * delta)


func _input(event: InputEvent) -> void:
	_handle_zoom(event)
	_handle_rotate(event)

func _handle_pan(delta: float) -> void:
	var input_dir := Vector3.ZERO

	# WASD movement on the ground plane (X/Z)
	if Input.is_key_pressed(KEY_W):
		input_dir.x += 1
		input_dir.z -= 1
	if Input.is_key_pressed(KEY_S):
		input_dir.x -= 1
		input_dir.z += 1
	if Input.is_key_pressed(KEY_D):
		input_dir.x -= 1
		input_dir.z -= 1
	if Input.is_key_pressed(KEY_A):
		input_dir.x += 1
		input_dir.z += 1

	if input_dir == Vector3.ZERO:
		return

	# Move relative to camera rig's facing direction (so WASD rotates with camera)
	input_dir = input_dir.normalized()
	var forward := -global_transform.basis.z
	var right := global_transform.basis.x
	var move := (right * input_dir.x + forward * input_dir.z) * pan_speed * delta

	# Keep movement flat (no flying)
	move.y = 0
	global_position += move

func _handle_zoom(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			target_zoom_dist = clamp(target_zoom_dist - zoom_speed, min_zoom, max_zoom)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			target_zoom_dist = clamp(target_zoom_dist + zoom_speed, min_zoom, max_zoom)



func _zoom_by(amount: float) -> void:
	# Vector from rig (this node) to camera, in rig-local space
	var offset: Vector3 = cam.position

	# Current distance from rig
	var dist: float = offset.length()
	if dist <= 0.0001:
		return

	# Adjust distance (mouse wheel step)
	dist = clamp(dist + amount, min_zoom, max_zoom)

	# Keep same direction, just change distance
	cam.position = offset.normalized() * dist


func _handle_rotate(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E:
			target_yaw += deg_to_rad(90)
		elif event.keycode == KEY_Q:
			target_yaw -= deg_to_rad(90)
