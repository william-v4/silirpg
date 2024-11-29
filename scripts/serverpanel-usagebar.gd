extends TextureProgressBar
## counter colour at 100
@export var HIGH_COLOUR = Color(1, 0.25, 0) # ORANGE-RED
## counter colour at 0
@export var LOW_COLOUR = Color(0.2, 0.5, 1) # blue

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# update progress bar colour as value changes (will be run whenever progress bar detects change)
func _on_value_changed(value):
	# change colour of bar according to interpolation between LOW_COLOUR to HIGH_COLOUR based on percentage of value
	tint_progress = LOW_COLOUR.lerp(HIGH_COLOUR, value / 100)
	# do the same for indicator text
	$indicator.modulate = tint_progress
	# and the same for the label
	$Label.modulate = tint_progress
