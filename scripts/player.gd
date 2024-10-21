extends CharacterBody2D

signal quitGameSignal
signal restartGameSignal

@export var speed = 30
var screen_size

var attacking = false
var attack_duration = 0.8
var attack_timer = 0.0

var last_direction = ""

var interacting = false
var dead = false

var tipo_porta = ""

func _ready() -> void:
	#$InfoPress.visible = false
	#$Information.visible = false
	screen_size = get_viewport_rect().size

func _process(delta: float) -> void:
	velocity = Vector2.ZERO
		
	if Input.is_action_pressed("move_right") and not $Information.visible and not dead:
		velocity.x += 1
	if Input.is_action_pressed("move_left") and not $Information.visible and not dead:
		velocity.x -= 1
	if Input.is_action_pressed("move_down") and not $Information.visible and not dead:
		velocity.y += 1
	if Input.is_action_pressed("move_up") and not $Information.visible and not dead:
		velocity.y -= 1

	if velocity.length() > 0 and not attacking and not dead:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	elif not attacking and not dead:
		$AnimatedSprite2D.stop()
	
	if not attacking:
		move_and_slide()
		
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

	move_and_slide()

	if velocity.x > 0 and not attacking and not dead:
		last_direction = "walk_right"
		$AnimatedSprite2D.animation = "walk_right"
		$AnimatedSprite2D.flip_h = false
	elif velocity.x < 0 and not attacking and not dead:
		last_direction = "walk_left"
		$AnimatedSprite2D.animation = "walk_left"
		$AnimatedSprite2D.flip_h = true
	elif velocity.y < 0 and not attacking and not dead:
		last_direction = "walk_up"
		$AnimatedSprite2D.animation = "walk_up"
	elif velocity.y > 0 and not attacking and not dead:
		last_direction = "walk_down"
		$AnimatedSprite2D.animation = "walk_down"
	elif not attacking and not dead:
		$AnimatedSprite2D.animation = "idle"
	
	if dead and $AnimatedSprite2D.animation != "dead":
		$AnimatedSprite2D.animation = "dead"
		$AnimatedSprite2D.play()
	
	if Input.is_action_just_pressed("attack") && not interacting and not dead:
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
		$InfoPress.visible = false

func _on_totem_pergaminho_body_entered(body: Node2D) -> void:
	if body == self:
		interacting = true
		$Information/Label.text = "Onde o peso da alma não se abate, o caminho será seguro e sem derrota."
		$Information/Button.text = "Fechar"
		if not $Information/Button.is_connected("pressed", _on_button_pressed):
			$Information/Button.connect("pressed", _on_button_pressed)
		$InfoPress.visible = true


func _on_totem_pergaminho_body_exited(body: Node2D) -> void:
	if body == self:
		interacting = false
		$InfoPress.visible = false
		$Information.visible = false
		if $Information/Button.is_connected("pressed", _on_button_pressed):
			$Information/Button.disconnect("pressed", _on_button_pressed)


func _on_button_pressed() -> void:
	$Information.visible = false

func _on_button_pressed_open_door() -> void:
	var current_name_scene = get_tree().current_scene.name
	if tipo_porta == "Pena":
		print("Passou")
		if current_name_scene == "Level1":
			get_tree().change_scene_to_file("res://scenes/level_2.tscn")
		elif current_name_scene == "Level2":
			get_tree().change_scene_to_file("res://scenes/level_3.tscn")
		elif current_name_scene == "Level3":
			get_tree().change_scene_to_file("res://scenes/level_4.tscn")
		elif current_name_scene == "Level4":
			get_tree().change_scene_to_file("res://scenes/level_5.tscn")
		elif current_name_scene == "Level5":
			get_tree().change_scene_to_file("res://scenes/level_6.tscn")
	else:
		dead = true
		interacting = false
		$Information.visible = false
		$InfoPress.visible = false
		print("Morreu")

func _on_area_porta_emit_body_entered(tipo_porta_func) -> void:
	tipo_porta = tipo_porta_func
	interacting = true
	$Information/Label.text = "Deseja abrir a porta e enfrentar as consequências ?"
	$Information/Button.text = "Abrir"
	if not $Information/Button.is_connected("pressed", _on_button_pressed_open_door):
		$Information/Button.connect("pressed", _on_button_pressed_open_door)
	$InfoPress.visible = true


func _on_area_porta_emit_body_exited() -> void:
	interacting = false
	$InfoPress.visible = false
	$Information.visible = false
	if $Information/Button.is_connected("pressed", _on_button_pressed_open_door):
		$Information/Button.disconnect("pressed", _on_button_pressed_open_door)
	
func _on_AnimatedSprite2D_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "dead":
		_on_player_dead()

func _on_player_dead() -> void:
	$ScreenDead.visible = true

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

func quitGame() -> void:
	restartGameSignal.emit()

func restartGame() -> void:
	quitGameSignal.emit()
