extends CharacterBody2D

@export var speed = 100
var screen_size

var attacking = false
var attack_duration = 0.8
var attack_timer = 0.0

var last_direction = ""

func _ready() -> void:
	screen_size = get_viewport_rect().size

func _process(delta: float) -> void:
	var velocity = Vector2.ZERO
		
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.length() > 0 and not attacking:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	elif not attacking:
		$AnimatedSprite2D.stop()
	
	if not attacking:
		move_and_slide()
		
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

	#move_and_slide()

	if velocity.x > 0 and not attacking:
		last_direction = "walk_right"
		$AnimatedSprite2D.animation = "walk_right"
		$AnimatedSprite2D.flip_h = false
	elif velocity.x < 0 and not attacking:
		last_direction = "walk_left"
		$AnimatedSprite2D.animation = "walk_left"
		$AnimatedSprite2D.flip_h = true
	elif velocity.y < 0 and not attacking:
		last_direction = "walk_up"
		$AnimatedSprite2D.animation = "walk_up"
	elif velocity.y > 0 and not attacking:
		last_direction = "walk_down"
		$AnimatedSprite2D.animation = "walk_down"
	elif not attacking:
		$AnimatedSprite2D.animation = "idle"
	
	if Input.is_action_just_pressed("attack"):
		attacking = true
		attack_timer = attack_duration
		if last_direction == "walk_right":
			$AnimatedSprite2D.animation = "attack_right"
		elif last_direction == "walk_left":
			$AnimatedSprite2D.animation = "attack_left"
		elif last_direction == "walk_up":
			$AnimatedSprite2D.animation = "attack_up"
		elif last_direction == "walk_down":
			$AnimatedSprite2D.animation = "attack_down"
		else:
			$AnimatedSprite2D.animation = "attack_down"
		$AnimatedSprite2D.play()

	if attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			attacking = false
			$AnimatedSprite2D.stop()
