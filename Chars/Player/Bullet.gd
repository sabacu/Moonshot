extends Area2D

var velocity = Vector2(350,0)

func _process(delta):
	velocity.y += gravity*delta
	position += velocity * delta
	rotation = velocity.angle()

func contact():
	queue_free()

func _on_Bullet_body_entered(_body):
	contact()
