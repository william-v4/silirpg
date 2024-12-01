extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	# first, hide what we don't have
	$datacenter.hide()
	# and also show anything if we have initially
	update()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

## called by player to update inventory gui
func update():
	print("inventory updated")
	# see if the player is holding a datacenter
	var currentdatacenter = $"../..".datacenter_in_hand
	# if yes (hands aren't empty), show datacenter inventory entry and update inventory label to match the type of server
	if currentdatacenter != null:
		$datacenter.show()
		$datacenter/servertype.text = datacenter.labels[currentdatacenter]
	# otherwise, hide it
	else:
		$datacenter.hide()
	
