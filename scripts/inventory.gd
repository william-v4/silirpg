extends Control

# nodes of the food slots
const foodnodenames := {
	food.type.COFFEE: "coffee",
	food.type.SALAD: "salad",
	food.type.NOODLES: "noodles"
}

# Called when the node enters the scene tree for the first time.
func _ready():
	# first, hide what we don't have
	$datacenter.hide()
	# and also show anything if we have initially
	update()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# called by player to update inventory gui
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
	# iterate through player food inventory
	for x in $"../..".inventory:
		#         node name         inventory amount
		fooditems(foodnodenames[x], $"../..".inventory[x])
	
	
func fooditems(name : String, amount : int):
	print("updating " + str(name) + " to " + str(amount))
	# for the corresponding
	var entrynode = get_node(name)
	# check amount
	if amount == 0:
		# hide inventory slot if there are none of that item
		entrynode.hide()
	# otherwise, show the inventory slot and update its counter to match the amount of that item
	else:
		entrynode.show()
		entrynode.get_node("count").text = str(amount)
