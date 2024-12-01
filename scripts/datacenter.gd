extends StaticBody3D
class_name datacenter
## the different types of servers
enum serversizes {
	SMALL,
	MEDIUM,
	LARGE
}
## server size labels
var labels : Dictionary = {
	serversizes.SMALL: "S",
	serversizes.MEDIUM: "M",
	serversizes.LARGE: "L"
}
## color of label when server online
@export var ONLINE_COLOUR = Color(0, 0.75, 0.5) # green
## color of label when server offline
@export var OFFLINE_COLOUR = Color(1, 0.75, 0) # yellow
## whether the server is online or not (money is only made if it's online)
var online : bool = false
## server disk usage
var usage = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	print("datacenter built at: " + str(transform))
	# set status
	status(false)
	

# constructor (call when creating object)
func init(size : serversizes):
	## server type
	var serversize = size
	# add the corresponding server racks
	buildracks(size)
	# update outside label to match size
	$sizelabel.text = labels.get(size)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func status(online : bool):
	online = online
	if online:
		$sizelabel.modulate = ONLINE_COLOUR
	else:
		$sizelabel.modulate = OFFLINE_COLOUR

# populate datacenters with server racks based on size
func buildracks(size : serversizes):
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
