extends Control

## array of hashes
var hashes := []
## colour if user succeeds
@export var SUCCESS := Color(0, 1, 0) # green
## colour if user fails
@export var FAILURE := Color(1, 0, 0) # red
## time to wait after minigame finishes
@export var EXIT_DELAY = 2
# Called when the node enters the scene tree for the first time.
func _ready():
	# hide the result label
	$result.hide()
	# generate between 10 and 20 hashes
	for i in range(randi_range(10, 20)):
		# reset rng every time
		randomize()
		# generate float, hash the float, and then append to array
		hashes.append( str( randf() ).sha256_text() )
	# pick a hash from the array to be the expected one 
	$expected.text = hashes.pick_random()
	# pick another hash to be current hash to display
	$current.text = hashes.pick_random()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_refresh():
	# pick new hash
	var newhash = hashes.pick_random()
	# if it's the same hash
	if newhash == $current.text:
		# pick another
		newhash = hashes.pick_random()
	# set the new hash
	$current.text = newhash


func _on_verify():
	$result.show()
	# if the 2 hashes match
	if $current.text == $expected.text:
		# let user know
		$result.text = "update success"
		# and colour accordingly
		$result.modulate = SUCCESS
		
		# get datacenter node
		var datacenternode = Node3D
		if get_parent().get_parent() != null:
			datacenternode = get_parent().get_parent()
		# if it is indeed a datacenter
		if datacenternode is datacenter:
			# finish the update
			datacenternode.update()
	# if the update fails
	else:
		# let the user know
		$result.text = "update failed"
		# and colour accordingly
		$result.modulate = FAILURE
	# wait a few seconds (based on exit delay)
	await get_tree().create_timer(EXIT_DELAY).timeout
	# exit minigame
	queue_free()
