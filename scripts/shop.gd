extends Node3D

# node of the map - shop is under map > NavigationRegion3D > shop
var mapnode
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mapnode = get_parent().get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# TODO update price labels
	# for every node under shop
	for node in get_children():
		# run function for appropriate size
		if "product" in node.name:
			if "S" in node.name: labelupdator(node, datacenter.serversizes.SMALL)
			if "M" in node.name: labelupdator(node, datacenter.serversizes.MEDIUM)
			if "L" in node.name: labelupdator(node, datacenter.serversizes.LARGE)
# shortcut function for updating server pricetags
#                 server node          server size
func labelupdator(node : StaticBody3D, size : datacenter.serversizes):
	# update label in this format: 
	# price: $####
	# build energy: ##
	# unfortunately, we can't concatenate multi-line strings, so we're just gonna have to append like this
	node.get_node("Label3D").text = "price: $" + str(round(mapnode.prices[size]))
	node.get_node("Label3D").text += """ 
	build energy: """ + str(datacenter.buildenergies[size])
