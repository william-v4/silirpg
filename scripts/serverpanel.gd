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
	parent = get_parent()
	if parent is datacenter:
		onthemap = parent.onthemap
		playernode = parent.get_parent().get_node("player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if parent is datacenter:
		$usage.max_value = parent.capacity
		# $usage.value = parent.usage / parent.capacity * 100
		$usage.value = parent.usage
		$status.button_pressed = parent.online
		# print("parent status " + str(parent.online))
		# print("button status " + str($status.button_pressed))
		var timetoupdate = parent.get_node("update").time_left
		if timetoupdate == 0:
			$updatetime.text = "now"
			$updatetime/update.show()
		else:
			$updatetime/update.hide()
			$updatetime.text = str(int(timetoupdate / 60)) + " : " + str(int(timetoupdate) % 60)


func _on_status_button_up():
	if parent is datacenter:
		if $status.button_pressed and !parent.online and !parent.outdated:
			parent.status(true)
		if !$status.button_pressed and parent.online:
			parent.status(false)
		else:
			pass
			# $status.button_pressed = false


func logout():
	loggedout = true


func _on_update_pressed():
	# load update minigame
	var updategame = load("res://updateminigame.tscn").instantiate()
	add_child(updategame)
	playernode.changeenergy(-5)


func _on_clean_pressed():
	var defraggame = load("res://defrag.tscn").instantiate()
	add_child(defraggame)
	if parent is datacenter:
		playernode.changeenergy(-5)

# run when user presses upgrade
func _on_upgrade_pressed():
	if playernode.balance >= 100:
		playernode.transaction(-100)
	parent.capacity += 100


func _on_destroy_pressed():
	parent.destroy()
