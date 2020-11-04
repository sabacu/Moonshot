extends Area2D

var velocity = Vector2(0,0)

func _process(delta):
#	gravity = PlayerSheet.shoot_gravity
	velocity.y += gravity*delta*PlayerSheet.shoot_gravity
	velocity.x = PlayerSheet.shoot_force
	position += velocity * delta
	rotation = velocity.angle()

func contact():
	queue_free()

func _on_Bullet_body_entered(_body):
	contact()
