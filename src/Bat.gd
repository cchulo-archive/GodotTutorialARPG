extends KinematicBody2D

const FRICTION = 200
const FORCE = 150

var knockback = Vector2.ZERO


func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)

func _on_Hurtbox_area_entered(area):
	if area.get("knockback_vector") != null:
		knockback = area.knockback_vector * 150
