extends Node3D

##  lower quality textures for quicker debugging
@export var DEBUG = false
## datacenter object for instancing
var datacenterscene = preload("res://datacenter.tscn")
# TODO global datacenter prices in-game
var prices : Dictionary = {
	datacenter.serversizes.SMALL: 500,
	datacenter.serversizes.MEDIUM: 1000,
	datacenter.serversizes.LARGE: 3000
}
# Called when the node enters the scene tree for the first time
func _ready():
	# start daynight cycle (at sunrise)
	$AnimationPlayer.current_animation = "daynight"
	# $AnimationPlayer.seek(20)
	$AnimationPlayer.play()
	if !DEBUG: 
		# restore water quality
		$StaticBody3D/bay.get_surface_override_material(0).set_shader_parameter("normal_map_w", 2048)
	# initiate (constructor) the player
	$player.init(100, 1000)
	# start a timer for when the virus hits (between 8 and 12 min)
	$virus.start(randi_range(8*60, 12*60))
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# TODO gradually show build spots as game progresses
	if $player.xp >= 1000:
		$group2.show()
	if $player.xp >= 3000:
		$group3.show()
	if $player.xp >= 6000:
		$group4.show()
	# TODO datacenter inflation
	# for every price
	for x in prices:
		# add a bit to it per frame weighted with xp and delta (time per frame) for consistency across different hardware
		prices[x] += delta * $player.xp / 50
	# for every node in the scene	
	for node in get_children():
		# if it is a datacenter
		if node is datacenter:
			# update its price accordingly
			node.prices = prices
	


## emitted by player when the player interacts with an object that needs to be handled by map (when building for example)
## [param interactable] object in question
func _on_player_interact(interactable):
	print("interaction detected: " + str(interactable))
	# if the object in question is a dacenter build slot and the player has one just purchased, 
	if (interactable is buildspot) and $player.datacenter_in_hand != null:
		# instance a datacenter
		var datacenterinstance = datacenterscene.instantiate()
		# initialize it (with the size of the datacenter the player just purchased)
		datacenterinstance.init($player.datacenter_in_hand)
		# place it where the buildspot is (along with rotation)
		datacenterinstance.transform = interactable.transform
		# add it to the scene tree
		add_child(datacenterinstance)
		# delete the build spot
		interactable.free()
		# TODO take energy (scales with datacenter size)
		$player.changeenergy(-datacenterinstance.buildenergies[$player.datacenter_in_hand])
		# give player points for building server
		$player.xp += datacenter.xp[$player.datacenter_in_hand]
		# the player now no longer has a datacenter in hand
		$player.datacenter_in_hand = null
		# and tell player inventory UI about this change
		$player/HUD/inventory.update()

# called by virus timer when it's up
func _on_virus_timeout():
	# let player know
	$player/HUD/systemmessages.text = "a virus hit your servers"
	# for every node
	for x in get_children():
		# if it's a datacenter
		if x is datacenter:
			# prematurely trigger its update timer
			x.get_node("update").stop()
			x.get_node("update").start(1)
			# fill up its disk space
			x.usage = x.capacity
	# TODO wait a few seconds before clearing the message
	await get_tree().create_timer(30).timeout
	$player/HUD/systemmessages.text = ""
	# start new timer
	$virus.start(randi_range(8*60, 12*60))
