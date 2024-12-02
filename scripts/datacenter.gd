extends StaticBody3D
class_name datacenter
## the different types of servers
enum serversizes {
	SMALL,
	MEDIUM,
	LARGE
}
## server size labels
const labels : Dictionary = {
	serversizes.SMALL: "S",
	serversizes.MEDIUM: "M",
	serversizes.LARGE: "L"
}
## prices
const prices : Dictionary = {
	serversizes.SMALL: 500,
	serversizes.MEDIUM: 1000,
	serversizes.LARGE: 3000
}
## earn rates / second online
const rates : Dictionary = {
	serversizes.SMALL: 10,
	serversizes.MEDIUM: 20,
	serversizes.LARGE: 100
}
## xp gain when building
const xp : Dictionary = {
	serversizes.SMALL: 10,
	serversizes.MEDIUM: 20,
	serversizes.LARGE: 50
}
## color of label when server online
@export var ONLINE_COLOUR = Color(0, 0.75, 0.5) # green
## color of label when server offline
@export var OFFLINE_COLOUR = Color(1, 0.75, 0) # yellow
## server size
var serversize : serversizes
## price
var price : int
## earn rate / sec
var rate : float = 0
## whether the server is online or not (money is only made if it's online)
var online : bool = false
## server disk usage
var usage : float = 0
## total disk space
var capacity : float = 100
## if the server is out of date
var outdated := true
## will be true if the datacenter is indeed where it should be (on the map with player)
var onthemap : bool
## player node
var playernode : player

# Called when the node enters the scene tree for the first time.
func _ready():
	# check if the datacenter is on a map with the player
	if "Map" in get_parent().name:
		# if yes, set onthemap and playernode is used to reference player
		onthemap = true
		playernode = get_parent().get_node("player")
	# for debugging
	print("datacenter built at: " + str(transform))
	# set status
	status(false)

## constructor (call when creating object)
## [param size] type/size of server
func init(size : serversizes):
	# server type
	serversize = size
	# price and rates accordingly
	price = prices[size]
	rate = rates[size]
	# add the corresponding server racks
	buildracks(size)
	# update outside label to match size
	$sizelabel.text = labels.get(size)
	# randomize RNG
	randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# 50% chance of increasing usage when online
	if randi() % 2 and online and usage < capacity:
		# usage increase scales with server size (referencing price here)
		usage += delta / (price / 100)
	# if the disk is filled, the server becomes offline
	if usage >= capacity:
		status(false)

## set server status
## [param newstat] online or not
func status(newstat : bool):
	# set online accordingly
	online = newstat
	# and the colours as well as whether the payment cycle is running
	if online:
		$sizelabel.modulate = ONLINE_COLOUR
		$payment.start()
	else:
		$sizelabel.modulate = OFFLINE_COLOUR
		$payment.stop()

# show the server panel
func showpanel():
	# face the player away (so they don't click on it immediately after exiting, stuck forever in the haunting glow of the server panel)
	playernode.rotation.y = -$panel.rotation.y
	# pause player movement
	playernode.pause()
	# instantiate panel and add it to scene tree
	var serverpanelinstance = load("res://serverpanel.tscn").instantiate()
	add_child(serverpanelinstance)
	# wait for panel logout button to be pressed
	await serverpanelinstance.get_node("logout").pressed
	# if that happens, delete the panel
	serverpanelinstance.queue_free()
	# resume player movement
	playernode.resume()
	# delete the serverpanel if there is one to be deleted (apparently it cannot delete itself for some reason)
	# panelcloser()
	
func panelcloser():
	while get_node("serverpanel") != null:
		# logged out means it is to be deleted
		if get_node("serverpanel").loggedout:
			# delete the panel
			get_node("serverpanel").free()
			# renenable movement
			get_parent().get_node("player").resume()

# finish updating server
func update():
	# reset update timer to a value between 2 and 5 min
	$update.start(round(randf() * 180) + 120 )
	# server online
	status(true)
	# and no longer outdated
	outdated = false

# populate datacenters with server racks based on size
func buildracks(size : serversizes):
	serversize = size
	price = prices[size]
	# store the rack object to instance
	var rackscene : PackedScene
	# and their positions
	var positions : Array
	# check size
	match size:
		serversizes.SMALL:
			# load the corresponding server rack scene
			rackscene = load("res://rack_s.tscn")
			# set positions of racks
			positions = [
				Vector3(2, 1, 2), 
				Vector3(0, 1, 2), 
				Vector3(-2, 1, 2)
			]
		serversizes.MEDIUM:
			# load the corresponding server rack scene
			rackscene = load("res://rack_m.tscn")
			# set positions of racks
			positions = [
				Vector3(2, 1, 2), 
				Vector3(0, 1, 2), 
				Vector3(-2, 1, 2)
			]
		serversizes.LARGE:
			# load the corresponding server rack scene
			rackscene = load("res://rack_l.tscn")
			# set positions of racks
			positions = [Vector3(0, 0.654, 2)]
	# add servers at the positions above
	for coords in positions:
		# make an instance of the rack
		var rackinstance = rackscene.instantiate()
		# move that rack to the location
		rackinstance.position = coords
		# add it to the scene tree
		add_child(rackinstance)

# destroy the server
func destroy():
	# make sure the server exists on a map
	if onthemap:
		# credit 80% of the server's value to the player
		playernode.transaction(round(price * 0.8))
		# instantiate a buildspot
		var buildspot = load("res://buildspot.tscn").instantiate()
		# put buildspot in its place exactly
		buildspot.transform = transform
		# add it to map (datacenter instanced under map)
		get_parent().add_child(buildspot)
		# resume player movement
		playernode.resume()
		# hide the datacenter
		hide()
		# delete it when ready
		queue_free()

# makes server out of date (called when update timer up or by virus)
func _on_update_expired():
	# server goes offline
	status(false)
	# server now outdated
	outdated = true
	print("server out of date")

# run when the payment timer runs out (every sec)
func _on_payment_cycle():
	# if the datacenter is on a map with the player
	if onthemap:
		# credit the player with the earn rate of the server
		playernode.transaction(rates[serversize])
		# give the player an experience point for uptime
		playernode.xp += 1
		# restart timer
		$payment.start()
