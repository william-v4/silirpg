extends CharacterBody3D


@export var SPEED = 2
# const JUMP_VELOCITY = 4.5
var direction := Vector3.ZERO
var agent : NavigationAgent3D

func _ready():
	agent = $NavigationAgent3D
	_newposition()

func _physics_process(delta):
	if agent.is_navigation_finished():
		$AnimationPlayer.stop()
		velocity = Vector3.ZERO
		if $nextposition.is_stopped():
			# print("Jensen navigation finished")
			$nextposition.start()
	direction = (agent.get_next_path_position() - position).normalized()
	# print(agent.get_next_path_position())
	
	#look_at(Vector3(direction.y, 0, direction.z) + position)
	velocity = velocity.move_toward(direction * SPEED, delta)
	look_at(Vector3(velocity.x, 0, velocity.z) + position)
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# print(velocity)
	#if velocity > Vector3.ZERO and !$AnimationPlayer.current_animation == "walk":
		#print("walking")
		#$AnimationPlayer.play("walk")
	#elif !$AnimationPlayer.current_animation == "RESET":
		#print("not")
		#$AnimationPlayer.play("RESET")
	#print(velocity > Vector3.ZERO)
	move_and_slide()

func _newposition():
	if get_parent() != null:
		#agent.set_navigation_map(get_parent().get_node("NavigationRegion3D").get_rid())
		agent.target_position = NavigationServer3D.region_get_random_point(get_parent().get_node("NavigationRegion3D").get_rid(), 1, false)
		#agent.target_position = get_parent().get_node("player").position
		#agent.target_position = Vector3(-60, 0, 0)
		# print("Jensen next target: " + str(agent.target_position))
		$AnimationPlayer.play("walk")
	# agent.target_position = Vector3(randf_range(-4, 4), 0, randf_range(-4, 4))
	
