class_name Player
extends CharacterBody3D

@onready var camera_mount: Node3D = $Camera_mount
@onready var animation_player: AnimationPlayer = $Visuals/mixamo_base/AnimationPlayer
@onready var visuals: Node3D = $Visuals


var SPEED : int = 3
const JUMP_VELOCITY : float = 4.5

var walking_speed: int = 3
var running_speed: int = 5

var running: bool = false

var is_locked: bool = false

@export var sens_horizontal: float = 0.4
@export var sens_vertical: float = 0.2


func _ready():
	Input.mouse_mode =Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens_horizontal))
		visuals.rotate_y(deg_to_rad(event.relative.x * sens_horizontal) ) # Keeps the model still
		camera_mount.rotate_x(deg_to_rad(-event.relative.y * sens_vertical))

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
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if !is_locked:
			if running:
				if animation_player.current_animation != "running":
					animation_player.play("running")
			else:
				if animation_player.current_animation != "walking":
					animation_player.play("walking")
			visuals.look_at(position + direction)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		if !is_locked:
			if animation_player.current_animation != "idle":
				animation_player.play("idle")
			
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	if  !is_locked:
		move_and_slide()

func p(message):
	PrintManager._print(message)
