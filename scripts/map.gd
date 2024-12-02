extends Node3D

##  lower quality textures for quicker debugging
@export var DEBUG = false
## datacenter object for instancing
var datacenterscene = preload("res://datacenter.tscn")

# Called when the node enters the scene tree for the first time
func _ready():
	# start daynight cycle (at sunrise)
	$AnimationPlayer.current_animation = "daynight"
	# $AnimationPlayer.seek(20)
	$AnimationPlayer.play()
	if !DEBUG: 
		# restore water quality
		$StaticBody3D/bay.get_surface_override_material(0).set_shader_parameter("normal_map_w", 2048)
	#var instance = datacenterscene.instantiate()
	#instance.position = Vector3(-60, 0, 0)
	#instance.init(instance.serversizes.SMALL)
	#add_child(instance)
	# initiate (constructor) the player
	$player.init(100, 4000)
	# start a timer for when the virus hits (between 8 and 12 min)
	$virus.start(randi_range(8*60, 12*60))
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



## called when the player interacts with an object
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
		# take energy
		$player.changeenergy(-datacenter.prices[$player.datacenter_in_hand]/50)
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
	# wait a few seconds before clearing the message
	await get_tree().create_timer(10).timeout
	$player/HUD/systemmessages.text = ""
	# start new timer
	$virus.start(randi_range(8*60, 12*60))
