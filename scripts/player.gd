extends CharacterBody2D

@export var speed = 100
var screen_size

var attacking = false
var attack_duration = 0.8
var attack_timer = 0.0

var last_direction = ""

var interacting = false

var tipo_porta = ""

func _ready() -> void:
	$InfoPress.visible = false
	$Information.visible = false
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

	move_and_slide()

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
	
	if Input.is_action_just_pressed("attack") && not interacting:
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
	
	if interacting and Input.is_action_just_pressed("action_e"):
		$Information.visible = true

func _on_totem_pergaminho_body_entered(body: Node2D) -> void:
	if body == self:
		interacting = true
		$Information/Label.text = "Onde o peso da alma não se abate, o caminho será seguro e sem derrota."
		$Information/Button.text = "Fechar"
		$Information/Button.connect("pressed", _on_button_pressed)
		$InfoPress.visible = true


func _on_totem_pergaminho_body_exited(body: Node2D) -> void:
	if body == self:
		interacting = false
		$InfoPress.visible = false
		$Information.visible = false


func _on_button_pressed() -> void:
	$Information.visible = false

func _on_button_pressed_open_door() -> void:
	if tipo_porta == "Pena":
		print("Passou")
		get_tree().change_scene_to_file("res://scenes/level_2.tscn")
	else:
		$AnimatedSprite2D.animation = "dead"
		$AnimatedSprite2D.play()
		print("Morreu")
	print(tipo_porta)

func _on_area_porta_emit_body_entered(tipo_porta_func) -> void:
	tipo_porta = tipo_porta_func
	interacting = true
	$Information/Label.text = "Deseja abrir a porta e enfrentar as consequências ?"
	$Information/Button.text = "Abrir"
	$Information/Button.connect("pressed", _on_button_pressed_open_door)
	$InfoPress.visible = true


func _on_area_porta_emit_body_exited(tipo_porta) -> void:
	interacting = false
	$InfoPress.visible = false
	$Information.visible = false
