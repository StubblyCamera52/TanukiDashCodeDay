extends Sprite3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform


func _physics_process(delta):
	var raycast = $"../RayCast3D"
	global_position = Vector3($"..".position.x,raycast.get_collision_point().y,$"..".position.z)-(raycast.get_collision_normal()*0.1)
	global_transform = align_with_y(global_transform, raycast.get_collision_normal())
	
