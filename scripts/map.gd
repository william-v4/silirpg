extends Node3D

## makes some things more verbose and some textures lower quality for easier debugging
@export var DEBUG = true

# Called when the node enters the scene tree for the first time.
func _ready():
	if !DEBUG: 
		# restore water quality
		$StaticBody3D/bay.get_surface_override_material(0).set_shader_parameter("normal_map_w", 2048)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
