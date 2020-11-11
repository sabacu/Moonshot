extends KinematicBody2D

var target_fps = 60
var acceleration = 20
var max_speed = 100
var friction = 10
var air_resistance = 1
var gravity = 10

var shoot_direction = 1
var playing_shield_fx = false

var motion = Vector2.ZERO
var can_move = true
var jumping = false
var shooting = false
var pre_bullet = preload("res://Chars/Player/Bullet.tscn")
var pre_head = preload("res://Chars/Player/Head_Rigid_Body.tscn")
var pre_head_f = preload("res://Chars/Player/Head_Rigid_Body_flipped.tscn")

signal energy_changed
signal energy_bullet_changed
signal energy_head_changed
signal energy_shield_changed

func _process(_delta):
	_render_shield()
	if PlayerSheet.acvite_shield and not playing_shield_fx:
		$sprite/head/head_shield.visible = true
		$sprite/body_shield.visible = true
		$shield_fx.wait_time = rand_range(2,15)
		$shield_fx.start()
		playing_shield_fx = true
	elif not PlayerSheet.acvite_shield:
		$sprite/head/head_shield.visible = false
		$sprite/body_shield.visible = false
		$shield_fx.stop()

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
			$sprite/body_shield.flip_h = x_input < 0
			$sprite/head/head_shield.flip_h = x_input < 0
			
			if x_input <0:
				shoot_direction = -1
				$sprite/head/muzzle.position.x = -30
				PlayerSheet.sprite_flipped = true
			else:
				shoot_direction = 1
				$sprite/head/muzzle.position.x = 30
				PlayerSheet.sprite_flipped = false
			if not jumping:
				$anim.play("walk")
		
		motion.y += gravity * delta * target_fps
		if test_move(transform,Vector2.DOWN):
			jumping = false
			if x_input == 0:
				$anim.play("idle")
				motion.x = lerp(motion.x, 0, friction * delta)
			if Input.is_action_just_pressed("jump"):
				$audio_controller/jump.play()
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
	if PlayerSheet.bullet_energy > 0 and not shooting:
		shooting = true
		PlayerSheet.bullet_energy -= 1
		$audio_controller/bullet.play()
		$sprite/anim.play("shoot_mode")
		yield ($sprite/anim,"animation_finished")
		var b = pre_bullet.instance()
		owner.add_child(b)
		emit_signal("energy_bullet_changed")
		b.position = $sprite/head/muzzle.global_position
		b.rotation = $sprite/head/muzzle.rotation_degrees
		b.apply_impulse(Vector2(),Vector2(PlayerSheet.shoot_force*shoot_direction,0).rotated($sprite/head/muzzle.rotation))
		shooting = false
		$sprite/anim.play_backwards("shoot_mode")
		yield ($sprite/anim,"animation_finished")
		$sprite/anim.play("idle")
	else:
		$audio_controller/no_energy.play()
		emit_signal("energy_bullet_changed")

func launch():
	if PlayerSheet.head_energy > 0:
		$sprite/head.visible = false
		if shoot_direction > 0:
			var head = pre_head.instance()
			owner.add_child(head)
			head.position = position + Vector2(0,-50)
			can_move = false
		else:
			var head = pre_head_f.instance()
			owner.add_child(head)
			head.position = position + Vector2(0,-50)
			can_move = false
	else:
		$audio_controller/no_energy.play()
		emit_signal("energy_head_changed")

func return_function(target_position):
	global_position = target_position
	$sprite/head.visible = true
	can_move = true

func _render_shield():
	if PlayerSheet.max_shield_energy > 9:
		$sprite/body_shield.texture = preload("res://art_open_files/body_shield_sheet_5.png")
		$sprite/head/head_shield.texture = preload("res://art_open_files/head_shield_sheet_5.png")
		return
	if PlayerSheet.max_shield_energy > 6:
		$sprite/body_shield.texture = preload("res://art_open_files/body_shield_sheet_3.png")
		$sprite/head/head_shield.texture = preload("res://art_open_files/head_shield_sheet_3.png")
		return
	if PlayerSheet.max_shield_energy > 3:
		$sprite/body_shield.texture = preload("res://art_open_files/body_shield_sheet_2.png")
		$sprite/head/head_shield.texture = preload("res://art_open_files/head_shield_sheet_2.png")
		return

func _on_shield_fx_timeout():
	$sprite_shield_fx.rotation_degrees += rand_range(15,90)
	$anim_fx.play("cicle")
	playing_shield_fx = false
	
