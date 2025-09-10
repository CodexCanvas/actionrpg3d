class_name Player
extends CharacterBody3D

@onready var camera_mount: Node3D = $CameraMount
@onready var animation_player: AnimationPlayer = $Visuals/mixamo_base/AnimationPlayer
@onready var visuals: Node3D = $Visuals


var SPEED : int = 3
const JUMP_VELOCITY : float = 6

var walking_speed: int = 4
var running_speed: int = 9

var running: bool = false

var is_locked: bool = false
var is_reorienting: bool = false
var is_moving: bool = false

@export var sens_horizontal: float = 0.3
@export var sens_vertical: float = 0.1

@export var rotation_lerp_speed: float = 10.0


func _ready():
	Input.mouse_mode =Input.MOUSE_MODE_CAPTURED

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event is InputEventMouseMotion:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			return
		# Always rotate the player (camera rig) and the camera pitch
		rotate_y(deg_to_rad(-event.relative.x * sens_horizontal))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y * sens_vertical))
		camera_mount.rotation.x = clamp(camera_mount.rotation.x, deg_to_rad(-100), deg_to_rad(100))

		# Only counter-rotate the model if we are standing still and not currently reorienting.
		if !is_moving and !is_reorienting:
			visuals.rotate_y(deg_to_rad(event.relative.x * sens_horizontal))
		
		p("Player Y (deg): " + str(rotation_degrees.y))
		p("Visuals Y (deg): " + str(visuals.rotation_degrees.y))


func _physics_process(delta: float) -> void:
	if !animation_player.is_playing():
		is_locked = false

	if Input.is_action_pressed("kick"):
		if animation_player.current_animation != "kick":
			animation_player.play("kick")
			is_locked = true
		p("KICK!")
	
	if Input.is_action_pressed("run"):
		SPEED = running_speed
		running = true
	else :
		SPEED = walking_speed
		running = false
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		p("JUMP!")

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	is_moving = direction.length_squared() > 0
	
	if is_moving:
		is_reorienting = false # Cancel reorientation if we start moving
		
		# Slerp visuals to face movement direction
		var world_target_basis = Transform3D().looking_at(direction, Vector3.UP).basis
		var local_target_basis = transform.basis.inverse() * world_target_basis
		visuals.basis = visuals.basis.slerp(local_target_basis, delta * rotation_lerp_speed)
		
		if !is_locked:
			if running:
				if animation_player.current_animation != "running":
					animation_player.play("running")
			else:
				if animation_player.current_animation != "walking":
					animation_player.play("walking")
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else: # Player is idle
		var visual_y_rot_deg = wrapf(visuals.rotation_degrees.y, -180, 180)
		if abs(visual_y_rot_deg) >= 90.0 and not is_reorienting:
			is_reorienting = true

		if is_reorienting:
			# Slerp visuals to face forward
			var forward_direction = -transform.basis.z
			var world_target_basis = Transform3D().looking_at(forward_direction, Vector3.UP).basis
			var local_target_basis = transform.basis.inverse() * world_target_basis
			
			visuals.basis = visuals.basis.slerp(local_target_basis, delta * rotation_lerp_speed)

			# Check if we're done reorienting
			var angle_to_target = visuals.basis.get_rotation_quaternion().angle_to(local_target_basis.get_rotation_quaternion())
			if angle_to_target < deg_to_rad(1.0):
				is_reorienting = false
				visuals.basis = local_target_basis # Snap to final rotation
		
		if !is_locked:
			if animation_player.current_animation != "idle":
				animation_player.play("idle")
			
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if  !is_locked:
		move_and_slide()

func p(message):
	PrintManager._print(message)
