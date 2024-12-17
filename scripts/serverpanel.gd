extends Control

## parent of this node (supposed to be a datacenter but not always, such as in debugging)
var parent
var loggedout = false
## true if the panel is with the player on a map
var onthemap : bool
## for referencing the player
var playernode : player
# Called when the node enters the scene tree for the first time.
func _ready():
	print("panel opened")
	# parent is the datacenter, who instanced this scene
	parent = get_parent()
	# check if that is correct
	if parent is datacenter:
		# if it is, check if the datacenter is on a map with a player
		onthemap = parent.onthemap
		# try to get the player node
		playernode = parent.get_parent().get_node("player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if parent is datacenter:
		# constantly update usage bar parameters
		$usage.max_value = parent.capacity
		$usage.value = parent.usage
		# status button state is always same as datacenter status
		$status.button_pressed = parent.online
		# get update time from datacenter
		var timetoupdate = parent.get_node("update").time_left
		# if it's zero, instead of displaying time, display "now" and show the update button
		if timetoupdate == 0:
			$updatetime.text = "now"
			$updatetime/update.show()
		else:
			# otherwise, hide the update button and show the time as formatted min:sec
			$updatetime/update.hide()
			$updatetime.text = str(int(timetoupdate / 60)) + " : " + str(int(timetoupdate) % 60)

# called when status button is pressed
func _on_status_button_up():
	# if the panel is indeed under a datacenter
	if parent is datacenter:
		# if the button shows online, datacenter is not online, and datacenter is up to date (server should not start if outdated)
		if $status.button_pressed and !parent.online and !parent.outdated:
			# datacenter online
			parent.status(true)
		# if button shows offline while the datacenter is actually online, 
		if !$status.button_pressed and parent.online:
			# datacenter offline
			parent.status(false)

# called by logout button. loggedout tells datacenter to delete the panel
func logout():
	loggedout = true

# called by update button
func _on_update_pressed():
	# instantiate update minigame
	var updategame = load("res://updateminigame.tscn").instantiate()
	# add it to scene tree
	add_child(updategame)
	# deduct energy from player for this task
	playernode.changeenergy(-5)

# called by clean button
func _on_clean_pressed():
	# instantiate defragging game
	var defraggame = load("res://defrag.tscn").instantiate()
	# add it to scene tree
	add_child(defraggame)
	# deduct energy from player for this task
	playernode.changeenergy(-5)

# called by upgrade button
func _on_upgrade_pressed():
	# check if player has enough balance for new disk
	if playernode.balance >= 100:
		# if yes, deduct the cost of new disk
		playernode.transaction(-100)
	# TODO add another 100% to datacenter capacity (scaled with xp) [change weights]
	parent.capacity += round(500*100 / ((get_parent().playernode.xp + 1)) )

# called by destroy button
func _on_destroy_pressed():
	# tell datacenter to self destruct
	parent.destroy()
