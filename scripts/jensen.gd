extends CharacterBody3D


@export var SPEED = 2
# physics direction
var direction := Vector3.ZERO
# navigation agent
var agent : NavigationAgent3D

# run at start
func _ready():
	# set the navigation agent
	agent = $NavigationAgent3D
	# generate a new position
	_newposition()

# run continuously
func _physics_process(delta):
	# if jensen is done navigating
	if agent.is_navigation_finished():
		# stop walking animation
		$AnimationPlayer.stop()
		# set velocity to zero
		velocity = Vector3.ZERO
		# wait for next position timer to finish (wait a bit after done walking)
		if $nextposition.is_stopped():
			# restart the timer
			$nextposition.start()
	# direction is facing the next position of navigation agent from current
	direction = (agent.get_next_path_position() - position).normalized()
	# interpolate velocity based on speed
	velocity = velocity.move_toward(direction * SPEED, delta)
	# to appear natural, make jensen look the way he is walking
	look_at(Vector3(velocity.x, 0, velocity.z) + position)
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()

# generate new target position
func _newposition():
	# make sure jensen is on a map (instantiated under map)
	if get_parent() != null:
		# if yes, get a new random position from the map's (parent) navigationmesh
		agent.target_position = NavigationServer3D.region_get_random_point(get_parent().get_node("NavigationRegion3D").get_rid(), 1, false)
		# play walking animation
		$AnimationPlayer.play("walk")
	
