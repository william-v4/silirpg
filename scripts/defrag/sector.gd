extends Button

## whether this sector is data or cache (cache is false)
var data : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# 50/50 data or cache
	data = randi() % 2
	# update label accordingly
	if data:
		text = "data"
	else:
		text = "cache"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# when player presses on it
func _on_pressed():
	# emit deletion signal
	get_parent().deletion.emit(self)
