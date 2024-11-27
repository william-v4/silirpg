@tool
class_name typingeffect
extends RichTextEffect
## usage: [type speed = X]

# speed of typing (default: 80)
var speed : float = 80
var bbcode = "type"
var counter: int = 0

# main function called by godot (for every character of the text - charfx)
func _process_custom_fx(charfx: CharFXTransform) -> bool:
	# first, hide the character
	charfx.visible = false
	# for fading effect, change the opacity of the character based on the ratio of its TTL, weighted with speed, (elapsed_time - in sec) to its position in text (relative_index)
	charfx.color.a = min(charfx.elapsed_time * speed/3 / charfx.relative_index, 1.0)
	# then, if the character's TTL, weighted with the speed, meets the position of the character
	if charfx.elapsed_time * speed >= charfx.relative_index:
		# show the character
		charfx.visible = true
	# onto the next
	return true
