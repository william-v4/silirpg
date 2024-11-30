extends RayCast3D


# Called when the node enters the scene tree for the first time.
func _ready():
	# prevent the raycast from hitting the player itself
	add_exception($"../..")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
