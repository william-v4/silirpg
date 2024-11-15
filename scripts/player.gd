extends CharacterBody3D
# physics variables
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY_X : float = 0.2
const MOUSE_SENSITIVITY_Y : float = 0.1
# will be toggled false when player should not be moving (like when in text input)
var moving : bool = true

# constructor
func _ready() -> void:
	# capture player mouse for camera movement
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	# if the player presses pause key, pause the game
	if Input.is_action_just_pressed("pause"):
		moving = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	# only move if player is supposed to be moving
	if moving:
		keymovement(delta)

# runs whenever input is received (mouse, keyboard, controller)
func _input(event: InputEvent) -> void:
	# camera movement with mouse
	if ((event is InputEventMouseMotion) and moving):
		# camera to be moved
		var camera = $Camera3D
		# rotate the player left and right (about y axis)
		rotate_y(-deg_to_rad(event.relative.x) * MOUSE_SENSITIVITY_X)
		# rotate camera up and down (about x axis)
		camera.rotate_x(-deg_to_rad(event.relative.y) * MOUSE_SENSITIVITY_Y)
		# make sure player doesn't break neck (rotate camera vertically over 90 degrees)
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)

# for wasd + space
func keymovement(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()
