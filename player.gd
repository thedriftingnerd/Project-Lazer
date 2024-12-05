extends CharacterBody3D

const SPEED = 3.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var look_dir: Vector2 = Vector2.ZERO
@onready var camera = $Camera3D
@onready var footsteps_audio = $footsteps
var camera_sens = 0.1 #camera-sensitivity

var cap_mouse = true

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void: #mouse capture can be toggled via esc key
	if Input.is_action_just_pressed("pause"):
		cap_mouse = !cap_mouse
		if cap_mouse:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta: float) -> void:
	velocity.y = 0
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction != Vector3.ZERO:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)
		velocity.z = move_toward(velocity.z, 0, SPEED * delta)
	if direction != Vector3.ZERO and is_on_floor():
		if not footsteps_audio.playing:
			footsteps_audio.play() 
	else:
		if footsteps_audio.playing:
			footsteps_audio.stop()
	move_and_slide()
	_rotate_camera(delta)

func _input(event: InputEvent) -> void: #mouse camera movement
	if event is InputEventMouseMotion and cap_mouse:
		look_dir += Vector2(event.relative.x, event.relative.y) * camera_sens

func _rotate_camera(delta: float) -> void: #rotates player mased on mouse movement
	rotation.y -= look_dir.x * delta
	camera.rotation.x = clamp(camera.rotation.x - look_dir.y * delta, -1.5, 1.5)  # Clamp pitch to avoid flipping
	look_dir = Vector2.ZERO
