extends Label
## counter flashes this colour when increasing
@export var GAIN_COLOUR = Color(.5, 1, .5) # pastel green
## counter flashes this colour when decreasing
@export var LOSS_COLOUR = Color(1, .75, .25) # pastel orange
## counter flashes this colour when in the negatives
@export var OVERDRAFT_COLOUR = Color(1, 0, 0) # red
var targetnetworth = 0 # to store new networth to increment to
var value = 0 # current value shown by counter

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# always make sure label text matches value
	text = "$" + str(value)
	# watch if there is a new value. if there is, slowly increment counter to new value (for visual effect)
	if targetnetworth != value: 
		# if new value is increase
		if targetnetworth > value:
			# increment value
			value += 1
			# turn colour to GAIN_COLOUR
			modulate = GAIN_COLOUR
		# if new value is decrease
		if targetnetworth < value:
			# decrement value
			value -= 1
			# turn colour to LOSS_COLOUR
			modulate = LOSS_COLOUR
	# if player networth is negative, 
	if value < 0:
		# turn the counter red
		modulate = Color(1, 0, 0)
	# otherwise, leave it white when the value is not changing
	elif value == targetnetworth: 
		modulate = Color(1, 1, 1)
	
func update(newvalue):
	targetnetworth = newvalue
