extends CharacterBody3D
class_name player
# main stats
## amount of money player has
var balance : float = 0
## energy (aka stamina). Consumed by moving and doing tasks. Regained by rest and food. If player runs out, they burn out and game over. 
var energy : int = 100
## servers built in total
var xp : int = 0

# physics weights
@export var SPEED = 8
@export var JUMP_VELOCITY = 4.5
@export var MOUSE_SENSITIVITY_X : float = 0.2
@export var MOUSE_SENSITIVITY_Y : float = 0.1

## will be toggled false when player should not be moving (like when in text input or task)
var moving : bool = true
## will be true if paused
var paused : bool = false
## will be emitted when player clicks on an interactable object (along with the object in question)
signal interact(interactable : Node3D)
## the datacenter the player just purchased and is now holding
@export var datacenter_in_hand = datacenter.serversizes.LARGE
## inventory
var inventory = {
	food.type.COFFEE: 0,
	food.type.SALAD: 0,
	food.type.NOODLES: 0
}

# run as soon as node enters scene
func _ready() -> void:
	# hide unused UI elements
	$HUD/dialogue.hide()
	$HUD/systemmessages.hide()
	$HUD/tooltip.hide()
	# capture player mouse for camera movement
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
## constructor
## [param energy] initial energy
## [param balance] initial balance
func init(energy : int, balance : float):
	updateenergy(energy)
	updatebalance(balance)

func _physics_process(delta: float) -> void:
	# toggle for raycast debugging
	# print($"Camera3D/3D cursor".get_collider())
	# check if player wants to pause
	pauser()
	# only move if player is supposed to be moving
	if moving:
		keymovement(delta)
		# for player interactions
		interactor()

# runs whenever input is received (mouse, keyboard, controller)
func _input(event: InputEvent) -> void:
	# cruns when moving is enabled and mouse moves
	if ((event is InputEventMouseMotion) and moving):
		# camera movement
		cammovement(event)

# check if player is facing an object to interact with
func interactor():
	# get the object the player is facing
	var interactable = $"Camera3D/3D cursor".get_collider()
	#  if the player is facing an interactable object (not null)
	if interactable:
		# if that object is a slot to build a datacenter (named "buildspot")
		if"buildspot" in interactable.name:
			# change the UI tooltip accordingly
			$HUD/tooltip.text = "click to build"
		# otherwise, use the default
		else:
			$HUD/tooltip.text = "click to interact"
		# show the tooltip
		$HUD/tooltip.show()
		# and if the player clicks to interact with the object (and is allowed to move and not paused)
		if Input.is_action_just_released("click") and moving and !paused:
			# tell the map that the player decides to interact with this object
			interact.emit(interactable)
			# add build to total
			xp += 1
	# if there is no interactable object, leave the tooltip hidden
	else:
		$HUD/tooltip.hide()
	

#region setters
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
# updates balance (sets to new value)
func updatebalance(value):
	balance = value
	# update UI to match
	$HUD/balance.update(value)
# changes balance (change by amount)
func transaction(amount):
	balance += amount
	# update UI to match
	$HUD/balance.update(balance)
# changes inventory (changes by item, by amount)
func changeinventory(item, amount : int):
	# change item amount
	inventory[item] += amount
	# tell inventory GUI about it
	$HUD/inventory.update()
# updates inventory (sets amount of item)
func updateinventory(item, amount : int):
	# set item amount
	inventory[item] = amount
	# tell inventory GUI about it
	$HUD/inventory.update()
#endregion

#region movement
# for checking if the player wants to pause
func pauser():
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

# for wasd + space
func keymovement(delta):
	# add gravity to velocity (reminder gravity accelerates with time, so multiply by delta)
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump
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

## camera movement based on mouse
## [param event] passed by _input() loop
func cammovement(event : InputEvent):
	# camera to be moved
	var camera = $Camera3D
	# rotate the player left and right (about y axis) based on mouse movement in x axis
	rotate_y(-deg_to_rad(event.relative.x) * MOUSE_SENSITIVITY_X)
	# rotate camera up and down (about x axis) based on mouse movement in y axis
	camera.rotate_x(-deg_to_rad(event.relative.y) * MOUSE_SENSITIVITY_Y)
	# make sure player doesn't break neck (rotate camera vertically over 90 degrees)
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)
	# check if the player is facing an interactible object
#endregion
