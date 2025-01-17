extends RigidBody3D

signal stopped

# Called when the node enters the scene tree for the first time.
func shoot(angle, power):
	var force = Vector3.FORWARD.rotated(Vector3.UP, angle)
	apply_central_impulse(force * power)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _integrate_forces(state):
	if state.linear_velocity.length() < 0.1:
		stopped.emit()
		state.linear_velocity = Vector3.ZERO
	if position.y < -20:
		get_tree().reload_current_scene()
