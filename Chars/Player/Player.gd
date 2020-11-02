extends KinematicBody2D

var target_fps = 60
var acceleration = 20
var max_speed = 100
var friction = 10
var air_resistance = 1
var gravity = 10
var jump_force = 400
var motion = Vector2.ZERO
var can_move = true
var pre_bullet = preload("res://Chars/Player/Bullet.tscn")

var muzzle_velocity = 350
var muzzle_gravity = 150

func _physics_process(delta):

	if can_move:
		if Input.is_action_just_pressed("shoot"):
			shoot()
			return
		
		var x_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		if x_input != 0:
			motion.x += x_input * acceleration * delta * target_fps
			motion.x = clamp(motion.x, -max_speed, max_speed)
		else:
			#anim idle
			pass
		
		motion.y += gravity * delta * target_fps
		
		if test_move(transform,Vector2.DOWN):
			if x_input == 0:
				motion.x = lerp(motion.x, 0, friction * delta)
			if Input.is_action_just_pressed("jump"):
				motion.y = -jump_force
		
		else:
			if Input.is_action_just_released("jump") and motion.y < -jump_force/2:
				motion.y = -jump_force/2
			if x_input == 0:
				motion.x = lerp(motion.x, 0, air_resistance * delta)
		
		motion = move_and_slide(motion,Vector2.UP)

func shoot():
#	if get_tree().get_nodes_in_group("bullet_in_air").size() <= 0:
		var b = pre_bullet.instance()
		owner.add_child(b)
		b.velocity = b.transform.x * muzzle_velocity
		b.gravity = muzzle_gravity
		b.transform = $shape.global_transform
#		add_to_group("bullet_in_air")
