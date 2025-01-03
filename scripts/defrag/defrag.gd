extends Control
## time to wait after minigame finishes
@export var EXIT_DELAY = 2
## colour if user succeeds
@export var SUCCESS := Color(0, 1, 0) # green
## colour if user fails
@export var FAILURE := Color(1, 0, 0) # red
signal deletion(sector : Button)
# sector to instantiate
const sectorscene = preload("res://scripts/defrag/sector.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	# hide the result label
	$result.hide()
	# generate sectors on screen
	for y in range(96, 480, 128):
		for x in range(128, 896, 192):
			# instantiate the sector
			var sectorinstance = sectorscene.instantiate()
			# move it to the appropriate location
			sectorinstance.position = Vector2(x, y)
			# add it to the scene tree
			add_child(sectorinstance)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# when player clicks on a sector (emitted by clicked sector)
func _on_deletion(sector : Button):
	# try to get datacenter node
	var datacenternode = get_parent().get_parent()
	# if the sector is important data
	if sector.data:
		# show result label
		$result.show()
		# let the user know
		$result.text = "filesystem corrupted"
		# and colour accordingly
		$result.modulate = FAILURE
		# check if this mingame is running in a datacenter
		if datacenternode is datacenter:
			# if yes, crash the datacenter
			datacenternode.status(false)
			await get_tree().create_timer(EXIT_DELAY).timeout
			# exit the minigame
			queue_free()
	# otherwise, the data is safe to delete
	else:
		# delete the sector
		sector.queue_free()
		# count remaining cache sectors
		var cachesectors : int = 0
		# iterate through scene tree
		for x in get_children():
			# if x is a button, it's a sector
			if x is Button:
				# check if it has important data
				if !x.data:
					# if not, it is a cache sector
					cachesectors += 1
		# if there are no remaining cache sectors (other than current sector)
		if cachesectors == 1:
			# show result label
			$result.show()
			# let the user know
			$result.text = "cache cleared"
			# and colour accordingly
			$result.modulate = SUCCESS
			# free up space on datacenter (if this game is running in one)
			if datacenternode is datacenter:
				# half the usage
				datacenternode.usage = datacenternode.usage * 1/2
			# wait a bit before exiting
			await get_tree().create_timer(EXIT_DELAY).timeout
			# exit the minigame
			queue_free()
