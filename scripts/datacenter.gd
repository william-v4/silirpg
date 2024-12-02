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
	serversizes.SMALL: 100,
	serversizes.MEDIUM: 200,
	serversizes.LARGE: 600
}
## earn rates / second online
const rates : Dictionary = {
	serversizes.SMALL: 0.2,
	serversizes.MEDIUM: 0.5,
	serversizes.LARGE: 2
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

# Called when the node enters the scene tree for the first time.
func _ready():
	print("datacenter built at: " + str(transform))
	# set status
	status(false)
	usage = 50

# constructor (call when creating object)
func init(size : serversizes):
	## server type
	serversize = size
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
	# print("update status: " + str(outdated))
	if get_node("serverpanel") != null:
		if get_node("serverpanel").loggedout:
			get_node("serverpanel").free()
			get_parent().get_node("player").resume()
	#if "Map" in get_parent().name:
		#if get_node("serverpanel") == null and !get_parent().get_node("player").moving:
			#get_parent().get_node("player").resume()
	# 50% chance of increasing usage by delta
	if randi() % 2 and online:
		# print(usage)
		usage += delta / (price / 20)

func status(newstat : bool):
	online = newstat
	if online:
		$sizelabel.modulate = ONLINE_COLOUR
	else:
		$sizelabel.modulate = OFFLINE_COLOUR

func showpanel():
	var playernode = get_parent().get_node("player")
	playernode.rotation.y = -$panel.rotation.y
	playernode.pause
	var serverpanelinstance = load("res://serverpanel.tscn").instantiate()
	add_child(serverpanelinstance)

func update():
	# from 1 min to 3 min
	$update.start(round(randf() * 120) + 60 )
	status(true)
	outdated = false
	get_parent().get_node("player").changeenergy(-5)

	

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

func destroy():
	get_parent().get_node("player").transaction(price * 0.8)
	var buildspot = load("res://buildspot.tscn").instantiate()
	get_parent().add_child(buildspot)
	buildspot.transform = transform
	queue_free()

# when update timer runs out
func _on_update_expired():
	# server goes offline
	status(false)
	# server now outdated
	outdated = true
	print("server out of date")
