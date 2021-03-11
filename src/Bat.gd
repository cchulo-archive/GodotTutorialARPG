extends KinematicBody2D

const EnemyDeathEffect = preload("res://assets/Effects/EnemyDeathEffect.tscn")

export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200
export var FORCE = 150
export var WANDER_TOLERNACE = 4

var knockback = Vector2.ZERO
var velocity = Vector2.ZERO
onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var animatedSprite = $AnimatedSprite
onready var hurtbox = $Hurtbox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var animationPlayer = $AnimationPlayer

enum {
	IDLE,
	WANDER,
	CHASE
}

var state = CHASE

func _ready():
	pick_state()
	
func _process(delta):
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			query_state()
			
		WANDER:
			seek_player()
			query_state()
			
			var direction = global_position.direction_to(wanderController.target_position)
			velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
			animatedSprite.flip_h = velocity.x < 0
			
			if global_position.distance_to(wanderController.target_position) <= WANDER_TOLERNACE:
				pick_state()
			
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				var direction = global_position.direction_to(player.global_position)
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
			else:
				state = IDLE
			animatedSprite.flip_h = velocity.x < 0
			
func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE
		
func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * ACCELERATION
	velocity = move_and_slide(velocity)

func pick_state():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_timer(rand_range(1, 3))

func query_state():
	if wanderController.get_time_left() == 0:
		pick_state()

func _on_Hurtbox_area_entered(area):
	if area is SwordHitbox:
		stats.health -= area.damage
		knockback = area.knockback_vector * 150
		hurtbox.create_hit_effect()
		hurtbox.start_invincibility(0.4)

func _on_Stats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position


func _on_Hurtbox_invincibility_started():
	animationPlayer.play("Start")


func _on_Hurtbox_invincibility_ended():
	animationPlayer.play("Stop")
