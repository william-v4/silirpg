extends CharacterBody3D
# main stats
var networth = 0 # amount of money player has
var energy : int = 100 # energy (aka stamina). Consumed by moving and doing tasks. Regained by rest and food. If player runs out, they burn out and game over. 

# physics weights
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY_X : float = 0.2
const MOUSE_SENSITIVITY_Y : float = 0.1

var moving : bool = true # will be toggled false when player should not be moving (like when in text input)
var paused : bool = false # will be true if paused

# constructor
func _ready() -> void:
	# capture player mouse for camera movement
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# reset initial energy
	updateenergy(100)

func _physics_process(delta: float) -> void:
	# if the player presses pause key, pause the game
	if Input.is_action_just_pressed("pause") and !paused:
		# disable movement
		moving = false
		# release the mouse
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		# toggle paused
		paused = true
	# if the game is already paused, resume the game when window clicked on
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and paused:
		# re-enable movement
		moving = true
		# capture the mouse
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		# game no longer paused
		paused = false
	# only move if player is supposed to be moving
	if moving:
		keymovement(delta)

# setters
# updates energy (set to new value)
func updateenergy(value : int):
	energy = value
	# update UI to match
	$HUD/energy.update(value)
# changes energy (change by amount)
func changenergy(amount : int):
	energy += amount
	# update UI to match
	$HUD/energy.update(energy)
# updates networth (sets to new value)
func updatenetworth(value):
	networth = value
	# update UI to match
	$HUD/networth.update(value)
# changes networth (change by amount)
func transaction(amount):
	networth += amount
	# update UI to match
	$HUD/networth.update(networth)

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
		pass
		# velocity += get_gravity() * delta
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
