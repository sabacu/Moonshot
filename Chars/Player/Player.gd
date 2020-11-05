extends KinematicBody2D

var target_fps = 60
var acceleration = 20
var max_speed = 100
var friction = 10
var air_resistance = 1
var gravity = 10

var motion = Vector2.ZERO
var can_move = true
var jumping = false
var pre_bullet = preload("res://Chars/Player/Bullet.tscn")
var pre_head = preload("res://Chars/Player/Head_Rigid_Body.tscn")
var muzzle_velocity = 350
var muzzle_gravity = 150

func _physics_process(delta):
	if can_move:
		if Input.is_action_just_pressed("shoot"):
			shoot()
			return
		if Input.is_action_just_pressed("launch") and not jumping:
			launch()
			return
		var x_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		if x_input != 0:
			motion.x += x_input * acceleration * delta * target_fps
			motion.x = clamp(motion.x, -max_speed, max_speed)
			$sprite.flip_h = x_input < 0
			$sprite/head.flip_h = x_input < 0
			if not jumping:
				$anim.play("walk")
		
		motion.y += gravity * delta * target_fps
		if test_move(transform,Vector2.DOWN):
			jumping = false
			if x_input == 0:
				$anim.play("idle")
				motion.x = lerp(motion.x, 0, friction * delta)
			if Input.is_action_just_pressed("jump"):
				$anim.play("jump")
				jumping = true
				motion.y = -PlayerSheet.jump_force
		else:
			if Input.is_action_just_released("jump") and motion.y < -PlayerSheet.jump_force/2:
				motion.y = -PlayerSheet.jump_force/2
			if x_input == 0:
				motion.x = lerp(motion.x, 0, air_resistance * delta)
		motion = move_and_slide(motion,Vector2.UP)

func shoot():
	if PlayerSheet.energy > 0:
		var b = pre_bullet.instance()
		owner.add_child(b)
		PlayerSheet.energy -= 1
		b.velocity = b.transform.x * muzzle_velocity
		b.gravity = muzzle_gravity
		b.transform = $shape.global_transform

func launch():
	if PlayerSheet.energy > 0:
		$sprite/head.visible = false
		var head = pre_head.instance()
		owner.add_child(head)
		head.position = position + Vector2(0,-50)
		can_move = false

func return_function(target_position):
	global_position = target_position
	$sprite/head.visible = true
	can_move = true
