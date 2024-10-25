extends CharacterBody2D

@export var speed = 10
@export var detection_range = 100  # Alcance para detectar o jogador
@export var patrol_points = []  # Lista de vetores para os pontos de patrulha

var player = null
var current_patrol_index = 0
var is_chasing_player = false

func _ready() -> void:
	$RayCast2D.enabled = true
	player = get_node("/root/Level1/Player")

func _process(delta: float) -> void:
	if is_chasing_player:
		seek_player(delta)
	else:
		patrol(delta)

	update_animation()
	check_for_player()
	update_raycast_direction()

func update_animation() -> void:
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	if velocity.x > 0:
		$AnimatedSprite2D.animation = "walk_right"
		$AnimatedSprite2D.flip_h = false
	elif velocity.x < 0:
		$AnimatedSprite2D.animation = "walk_left"
		$AnimatedSprite2D.flip_h = true
	elif velocity.y < 0:
		$AnimatedSprite2D.animation = "walk_up"
	elif velocity.y > 0:
		$AnimatedSprite2D.animation = "walk_down"
	else:
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
