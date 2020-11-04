extends RigidBody2D

var dragging
var drag_start = Vector2()
var rocket_force = 3
var texture_padrao = preload("res://art_open_files/Sprite_base.png")

func _ready():
	$anim.play("idle")

func _input(event):
	if event.is_action_pressed("click") and not dragging:
		dragging = true
		drag_start = get_global_mouse_position()
	if event.is_action_released("click") and dragging and PlayerSheet.energy > 0:
		dragging = false
		var drag_end = get_global_mouse_position()
		var dir = drag_start - drag_end
		apply_impulse(Vector2.ZERO, dir * rocket_force)
		$anim.play("travel")
		yield ($anim,"animation_finished")
		$anim.play("idle")
		PlayerSheet.energy -= 1

func reach(position):
	print ("toutch test")
	get_parent().get_node("Player").return_function(position)
	queue_free()

func _on_detect_touch_body_entered(_body):
	reach(position)
