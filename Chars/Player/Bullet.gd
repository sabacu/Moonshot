extends RigidBody2D
#
#var velocity = Vector2(0,0)
#
#func _process(delta):
#	velocity.y += delta*PlayerSheet.shoot_gravity
#	velocity.x = PlayerSheet.shoot_force
#	position += velocity * delta

func contact():
	queue_free()

func _on_collision_body_entered(_body):
	contact()
