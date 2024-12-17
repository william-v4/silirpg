extends StaticBody3D
class_name buildspot

# Called when the node enters the scene tree for the first time.
func _ready():
	# custom text for the funnies
	$label.text = [
		"build here",
		"your dreams, right here",
		"sown here: the seeds of tomorrow",
		"eagerly awaiting a datacenter",
		"your business is appreciated",
		"one server at a time",
		"inifinite possibilities"
	].pick_random()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# TODO disable datacenter interaction layer if group (parent) hidden
	$CollisionShape3D.disabled = false if get_parent().visible else true
