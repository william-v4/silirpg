extends RichTextLabel
## speed for typewriter effect
const TYPESPEED : float = 80.0
## seconds it takes to type per character depending on speed (1/64 based on real world timing)
const TYPESEC : float = 1/64 * 80 / TYPESPEED
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	# empty the dialogue box
	# text = "[type]cuwzqkmktovhpigpwajmylsgzxyxbuvrjqfwnozwvckscyznxljsuyprwzmdvkhobpfgqetaujwzixmyhldrsfvkntbgpzaqjqchswltgrcboeifmdkuyzopvhsqjknfcxiwlzgmrbtkqvadyshjxasijdhkhasijeoghojawefoijaweoifoiawejtoijaweoigjoiawejoitjaw3oijoiw4a0r0gaw09erg0aawreg8awertawet82338rwhff"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	## time it takes to type out the contents of dialogue box (# of characters * sec/char)
	var typetime = text.length() * TYPESEC

## update dialogue box text
func update(message : String):
	# show the dialogue box
	show()
	# update text (and add typewriter effect flag)
	text = "[type]" + message
	# set and start a timer for the time it takes to type out the contents of dialogue box (# of characters * sec/char) with a few seconds added
	$typing.start(text.length() * TYPESEC + 10)
	

# when the timer finishes
func _on_typing_timeout():
	# hide the dialogue box
	hide()
