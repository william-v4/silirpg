extends TextureProgressBar
const HIGH_COLOUR = Color(0, 1, 0.6) # TEAL
const LOW_COLOUR = Color(1, 0.25, 0) # ORANGE-RED
const UPDATE_DELAY = 0.1 # weight (in seconds) used to smoothen out bar update
var targetvalue : int # value for smooth updating of progressbar (stored outside of update() or else there will be inaccuracies from clashing functions)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# always make sure indicator text matches progress bar value
	$indicator.text = str(value)
	# watch if there is a new value. if there is, slowly increment counter to new value (for visual effect)
	if targetvalue != value: 
		# if new value is increase
		if targetvalue > value:
			# increment value
			value += 1
		# if new value is decrease
		if targetvalue < value:
			# decrement value
			value -= 1
		# delay for smoothness
		await get_tree().create_timer(UPDATE_DELAY).timeout

# setter for new value (see line 22)
func update(newvalue):
	targetvalue = newvalue

# update progress bar colour as value changes (will be run whenever progress bar detects change)
func _on_value_changed(value: float) -> void:
	# change colour of bar according to interpolation between LOW_COLOUR to HIGH_COLOUR based on percentage of value
	tint_progress = LOW_COLOUR.lerp(HIGH_COLOUR, value / 100)
	# do the same for the icon
	$icon.modulate = tint_progress
	# and the same for indicator text
	$indicator.modulate = tint_progress
