extends KinematicBody2D

const FRICTION = 200
const FORCE = 150

var knockback = Vector2.ZERO
onready var stats = $Stats

func _ready():
	print(stats.max_health)
	print(stats.health)

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)

func _on_Hurtbox_area_entered(area):
	if area is SwordHitbox:
		stats.health -= 1
		knockback = area.knockback_vector * 150

func _on_Stats_no_health():
	queue_free()
