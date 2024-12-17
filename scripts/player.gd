extends CharacterBody3D
class_name player
# main stats
## amount of money player has
var balance : int = 0
## energy (aka stamina). Consumed by moving and doing tasks. Regained by rest and food. If player runs out, they burn out and game over. 
var energy : int = 100
## experience gained building and running servers
var xp : int = 0
## player name
var playername : String

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
@export var datacenter_in_hand = null
## inventory
var inventory = {
	food.type.COFFEE: 0,
	food.type.SALAD: 0,
	food.type.NOODLES: 0
}
## tooltip node so we don't have to type path every time
@export var tooltipnode : Label
## energy needed to build datacenter
@export var BUILD_ENERGY := 20
## will be true if player is actively in a 2D UI
var inpanel : bool = false
## player receives bonus every this many xp points
const XPBONUSPOINT = 500
## player receives this bonus amount
const BONUSAMOUNT = 500
## last xp value the player received a bonus at
var lastpayoutxp : int = 0
## variable for locking the xp indicator while message is shown
var xpmessage := false
## true when player dead
var dead := false

# run as soon as node enters scene
func _ready() -> void:
	# tooltip node
	tooltipnode = $HUD/tooltip
	# hide unused UI elements
	$HUD/dialogue.hide()
	$HUD/systemmessages.text = ""
	tooltipnode.hide()
	
## constructor
## [param energy] initial energy
## [param balance] initial balance
func init(energy : int, balance : int):
	updateenergy(energy)
	updatebalance(balance)
	# prompt for name
	# instance and add to scene tree the name input scene
	add_child( load("res://namebox.tscn").instantiate() )
	# face camera downwards for scenery
	$Camera3D.rotation_degrees.x = -85
	# pause movement
	pause()
	# play intro
	$background.play()

# constantly run
func _physics_process(delta: float) -> void:
	# toggle for raycast debugging
	# print($"Camera3D/3D cursor".get_collider())
	# check if player wants to pause (should only happen if within panel)
	if !inpanel:
		pauser()
	# only move if player is supposed to be moving
	if moving:
		keymovement(delta)
		# for player interactions
		interactor()
	# if player burns out and isn't already dead
	if energy <= 0 and !dead:
		# instance and add game over screen to scene
		add_child( load("res://gameover.tscn").instantiate() )
		# disable movement
		pause()
		# prevent further instantiations
		dead = true
	# eat when eat key pressed
	if Input.is_action_just_released("eat"):
		eat()
	# if there is no active message in the xp counter
	if !xpmessage:
		# display normally
		$HUD/xp.text = "XP: " + str(xp)
	# if player hits the amount of xp to get a bonus, and they haven't already gotten bonus for that level
	if xp % XPBONUSPOINT == 0 and xp != lastpayoutxp:
		# give xp bonus
		xppayout()

# runs whenever input is received (mouse, keyboard, controller)
func _input(event: InputEvent) -> void:
	# cruns when moving is enabled and mouse moves
	if ((event is InputEventMouseMotion) and moving):
		# camera movement
		cammovement(event)


#region interactions
# check if player is facing an object to interact with
func interactor():
	# get the object the player is facing
	var interactable = $"Camera3D/3D cursor".get_collider()
	#  if the player is facing an interactable object (not null)
	if interactable:
		# show the tooltip
		tooltipnode.show()
		# if that object is a slot to build a datacenter (named "buildspot")
		if interactable is buildspot:
			# change the UI tooltip accordingly
			tooltipnode.text = "click to build"
		# otherwise, use the default
			# and if the player clicks to interact with the object (and is allowed to move and not paused)
			if Input.is_action_just_released("click") and moving and !paused:
				# tell the map that the player decides to interact with this object
				interact.emit(interactable)
		# for the shop items
		elif "product" in interactable.name:
			# make sure hand is empty before purchasing
			if datacenter_in_hand == null:
				# run shopchecker for every server type
				if "S" in interactable.name:
					shopchecker(interactable, datacenter.serversizes.SMALL)
				elif "M" in interactable.name:
					shopchecker(interactable, datacenter.serversizes.MEDIUM)
				elif "L" in interactable.name:
					shopchecker(interactable, datacenter.serversizes.LARGE)
			# if not, the player already has a server in hand
			else:
				tooltipnode.text = "already holding a server"
		# if the player faces a selling bin in the shop
		elif "sellbin" in interactable.name:
			# prompt
			tooltipnode.text = "click to sell"
			# if player clicks
			if Input.is_action_just_released("click") and moving and !paused:
				# if player has a datacenter in hand
				if datacenter_in_hand != null:
					# TODO credit player with the price of that datacenter (use global price instead)
					transaction(get_parent().prices[datacenter_in_hand])
					# remove from hand
					datacenter_in_hand = null
					# tell inventory to update
					$HUD/inventory.update()
		# if player faces a panel placeholder
		elif "panel" in interactable.name:
			# prompt
			tooltipnode.text = "click to log in"
			# if player clicks
			if Input.is_action_just_released("click") and moving and !paused:
				# show the panel in the datacenter (parent of panel placeholder)
				interactable.get_parent().showpanel()
				# pause player movement
				pause()
		# if the player faces a food item in cafe bytes
		elif interactable is food:
			cafechecker(interactable)
		else:
			# if all of the above don't match, show generic message
			tooltipnode.text = ""
	# if there is no interactable object, leave the tooltip hidden
	else:
		tooltipnode.hide()

## run in interactor for every server in the shop
#                object in question     the size of that dataenter object
func shopchecker(interactable : Node3D, size : datacenter.serversizes):
	# TODO check if player has enough balance (use global price instead)
	if balance >= get_parent().prices[size]:
		# if yes, prompt to buy
		tooltipnode.text = "click to buy"
		# if player clicks
		if Input.is_action_just_released("click") and moving and !paused:
			# give the player the datacenter
			datacenter_in_hand = size
			# TODO deduct the price of that datacenter from balance (use global price instead)
			transaction(-get_parent().prices[size])
			# tell inventory about the change
			$HUD/inventory.update()
	# TODO if player does not have enough balance to purchase datacenter (use global price instead)
	elif balance < get_parent().prices[size]:
		# let player know
		tooltipnode.text = "insufficient funds"
	# if for whatever reason all of the above is not satisfied
	else:
		# hide the tooltip
		tooltipnode.hide()

## run for the food object player is interacting with
## [param food] the food object
func cafechecker(interactable : food):
	# get the price of that food object
	var foodprice = food.prices[interactable.foodtype]
	# check if player has enough balance to buy it
	if balance >= foodprice:
		# if yes, prompt to buy
		tooltipnode.text = "click to buy"
		# if player clicks
		if Input.is_action_just_released("click") and moving and !paused:
			# add a food object of that type to the inventory
			inventory[interactable.foodtype] += 1
			# deduct price from balance
			transaction(-foodprice)
			# tell inventory about the change
			$HUD/inventory.update()
	# otherwise, if the player has not enough balance to buy it
	elif balance < foodprice:
		# let the player know
		tooltipnode.text = "insufficient funds"
#endregion

# pay xp bonus
func xppayout():
	# congratulate player
	xpmessage = true
	$HUD/xp.text = "congrats on reaching " + str(xp) + ". you get a $" + str(BONUSAMOUNT) + " bonus"
	# reset last payout
	lastpayoutxp = xp
	# credit the player the bonus
	transaction(BONUSAMOUNT)
	# wait a few seconds before clearing the message
	await get_tree().create_timer(10).timeout
	# clear the message
	xpmessage = false

#region setters
## pause the game
func pause():
	# disable movement
	moving = false
	# release the mouse
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	# toggle paused
	paused = true
## resume the game
func resume():
	# re-enable movement
	moving = true
	# capture the mouse
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# game no longer paused
	paused = false
# updates energy (set to new value)
func updateenergy(value : int):
	energy = value
	# update UI to match
	$HUD/energy.update(value)
# changes energy (change by amount)
func changeenergy(amount : int):
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

#region controls
# for checking if the player wants to pause
func pauser():
	# if the player presses pause key, pause the game
	if Input.is_action_just_pressed("pause") and !paused:
		pause()
	# if the game is already paused, resume the game when window clicked on
	if Input.is_action_just_released("resume") and paused:
		resume()

# consume food in inventory (the most food before player is full)
func eat():
	# iterate through inventory
	for x in inventory:
		# calculate energy left to fill
		var hunger : int = 100 - energy
		# while the food has less energy than that to fill and the player has one of that food
		while food.energies[x] <= hunger and inventory[x] > 0:
			# remove it from the inventory
			inventory[x] -= 1
			# tell inventory about it
			$HUD/inventory.update()
			# credit the energy from that food
			changeenergy(food.energies[x])
			# recalculate energy left to fill
			hunger = 100 - energy

# for wasd + space
func keymovement(delta):
	# add gravity to velocity (reminder gravity accelerates with time, so multiply by delta)
	if not is_on_floor():
		velocity += get_gravity() * delta
		# player dies if fall
		if position.y < -20 and !dead:
			# instantiate game over screen
			var gameoverscreen = load("res://gameover.tscn").instantiate()
			# add to scene tree
			add_child(gameoverscreen)
			# disable movement
			pause()
			# change death messages
			gameoverscreen.get_node("title").text = "go seek help"
			gameoverscreen.get_node("subtitle").hide()
			# prevent further instantiations
			dead = true
	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# Get the input direction as a vector of directional inputs
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	# transpose that vector to that of the 3D space the player is facing
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	# if direction is more than zero, set velocity to it (weighted with speed)
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	# if direction is zero (no input), decelerate (move velocity to zero)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	# godot physics engine
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

# emitted when background sountrack player done playing
func _on_background_finished():
	# TODO load and play background soundtrack (pick random between 2)
	randomize()
	$background.stream = load("res://assets/audio/silirpg-ambient-remaster.mp3") if randi() % 2 else load("res://assets/audio/silirpg-ambient2.mp3")
	$background.play()
