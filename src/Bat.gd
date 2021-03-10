extends KinematicBody2D

const EnemyDeathEffect = preload("res://assets/Effects/EnemyDeathEffect.tscn")

export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200
export var FORCE = 150

var knockback = Vector2.ZERO
var velocity = Vector2.ZERO
onready var stats = $Stats

enum {
	IDLE,
	WANDER,
	CHASE
}

var state = CHASE

func _ready():
	print(stats.max_health)
	print(stats.health)
	
func _process(delta):
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			
		WANDER:
			pass
		CHASE:
			pass
			
func seek_player():
	pass

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)

func _on_Hurtbox_area_entered(area):
	if area is SwordHitbox:
		stats.health -= area.damage
		knockback = area.knockback_vector * 150

func _on_Stats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
