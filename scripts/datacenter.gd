extends StaticBody3D
## the different types of servers
enum serversizes {
	SMALL,
	MEDIUM,
	LARGE
}
## whether the server is online or not (money is only made if it's online)
var online : bool = false
## server disk usage
var usage = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# constructor (call when creating object)
func init(size : serversizes):
	## server type
	var serversize = size
	# add the corresponding server racks
	if size == serversizes.SMALL:
		# load the server rack scene
		var rack = load("res://assets/server-S.blend")
		# add servers at the following locations
		for coords in [
				Vector3(2, 1, 2), 
				Vector3(0, 1, 2), 
				Vector3(-2, 1, 2)
			]:
			# make an instance of the rack
			var instance = rack.instantiate()
			# move that rack to the location
			instance.position = coords

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
