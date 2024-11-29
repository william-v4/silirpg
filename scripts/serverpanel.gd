extends Control
## the different types of servers
enum serversizes {
	SMALL,
	MEDIUM,
	LARGE
}
## server type
var serversize : serversizes
## whether the server is online or not (money is only made if it's online)
var online : bool = false
## server disk usage
var usage = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
