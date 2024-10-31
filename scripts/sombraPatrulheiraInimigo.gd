extends CharacterBody2D

@export var speed = 10
@export var detection_range = 100  # Alcance para detectar o jogador
@export var patrol_points = []  # Lista de vetores para os pontos de patrulha
@export var damage = 10
@export var death_animation_duration = 1
@export var knockback_distance = 50  # Distância do recuo
@export var knockback_duration = 0.1
signal mini_boss_defeated

var life = 100
var player = null
var current_patrol_index = 0
var is_chasing_player = false
var is_collision_player = false
var dead = false

var knockback_timer = 0.0
var knockback_velocity = Vector2.ZERO

func _ready() -> void:
	$RayCast2D.enabled = true
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0]

func _process(delta: float) -> void:
	if not dead:
		if is_chasing_player:
			seek_player(delta)
		else:
			patrol(delta)
			
		update_animation()
		check_for_player()
		update_raycast_direction()

func _on_body_entered(body):
	if body == player:
		is_collision_player = true
		$DamageTimer.start()

func _on_body_exited(body):
	if body == player:
		is_collision_player = false
		$DamageTimer.stop()

func _on_damage_timer_timeout() -> void:
	if is_collision_player:
		Global.life -= damage
	
func update_animation() -> void:
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	
	if is_collision_player:
		$AnimatedSprite2D.animation = "atack"

	if velocity.x > 0 and not is_collision_player:
		$AnimatedSprite2D.animation = "walk_right"
		$AnimatedSprite2D.flip_h = false
	elif velocity.x < 0 and not is_collision_player:
		$AnimatedSprite2D.animation = "walk_left"
		$AnimatedSprite2D.flip_h = true
	elif velocity.y < 0 and not is_collision_player:
		$AnimatedSprite2D.animation = "walk_up"
	elif velocity.y > 0 and not is_collision_player:
		$AnimatedSprite2D.animation = "walk_down"
	elif not is_collision_player:
		$AnimatedSprite2D.animation = "idle"

func patrol(delta: float) -> void:
	var target = patrol_points[current_patrol_index]
	move_towards(target, delta)
	
	if position.distance_to(target) < 10:
		current_patrol_index = (current_patrol_index + 1) % patrol_points.size()

func seek_player(delta: float) -> void:
	var direction = (player.position - position).normalized()
	velocity = direction * speed
	move_and_slide()

func move_towards(target: Vector2, delta: float) -> void:
	var direction = (target - position).normalized()
	velocity = direction * speed
	move_and_slide()

func check_for_player() -> void:
	if $RayCast2D.is_colliding() and $RayCast2D.get_collider() == player:
		is_chasing_player = true
	else:
		is_chasing_player = false

func update_raycast_direction() -> void:
	if is_chasing_player:
		var direction_to_player = (player.position - position).normalized()
		$RayCast2D.target_position = direction_to_player * detection_range
	else:
		if velocity.length() > 0:
			$RayCast2D.target_position = velocity.normalized() * detection_range

func take_damage(amount: int, direction: Vector2) -> void:
	life -= amount
	print("Vida do inimigo:", life)
	if life <= 0:
		dead = true
		die()
	else:
		apply_knockback(direction)

func apply_knockback(direction: Vector2) -> void:
	knockback_velocity = direction.normalized() * -knockback_distance
	knockback_timer = knockback_duration

func _physics_process(delta: float) -> void:
	if knockback_timer > 0:
		velocity = knockback_velocity
		knockback_timer -= delta
	else:
		velocity = Vector2.ZERO  # Parar o recuo após o término do tempo
	move_and_slide()

func die() -> void:
	$AnimatedSprite2D.animation = "death"  # Nome da animação de morte
	$AnimatedSprite2D.play()
	
	var death_timer = Timer.new()
	death_timer.wait_time = death_animation_duration
	death_timer.one_shot = true
	death_timer.connect("timeout", _on_death_animation_complete)
	add_child(death_timer)
	death_timer.start()
	
	if is_in_group("mini-boss"):
		emit_signal("mini_boss_defeated")

func _on_death_animation_complete() -> void:
	queue_free()
