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

func _physics_process(delta):
	
	if test_move(transform,Vector2.DOWN):
		reach()
	
	var x_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	if x_input != 0:
		motion.x += x_input * acceleration * delta * target_fps
		motion.x = clamp(motion.x, -max_speed, max_speed)
		
	motion.y += gravity * delta * target_fps
	
	if x_input == 0:
		motion.x = lerp(motion.x, 0, friction * delta)
		if Input.is_action_just_pressed("launch"):
			$anim.play("travel")
			motion.y = -jump_force
	else:
		if Input.is_action_just_released("launch") and motion.y < -jump_force/2:
			$anim.play("idle")
			motion.y = -jump_force/2
		if x_input == 0:
			motion.x = lerp(motion.x, 0, air_resistance * delta)
		
	motion = move_and_slide(motion,Vector2.UP)

func reach():
	queue_free()
