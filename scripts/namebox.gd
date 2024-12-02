extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# if enter pressed
	if Input.is_action_just_pressed("ui_accept"):
		submit()

# run when submit button pressed
func _on_submit_pressed():
	submit()

func submit():
	# sanitize input for whitespace or line breaks
	$input.text.strip_edges(true, true)
	# assuming this is instanced by the player, set the playername variable to text inside box
	get_parent().playername = $input.text
	# resume player movement
	get_parent().resume()
	# say hello
	get_parent().get_node("./HUD/dialogue").update("hello, " + $input.text)
	# and then leave the scene
	queue_free()
