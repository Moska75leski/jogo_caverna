extends CharacterBody2D

signal quitGameSignal
signal restartGameSignal

signal startPosition

@export var speed = 30
var screen_size

var attacking = false
var attack_duration = 0.8
var attack_timer = 0.0

var last_direction = ""

var interacting = false
var dead = false
var key = false

var tipo_porta = ""

@export var attack_damage = 20
var current_enemy = null
var cura_cooldown = 30
var tempo_ultima_cura = -cura_cooldown


func _ready() -> void:
	$Hud/InfoPress.visible = false
	$Hud/Information.visible = false
	startPosition.emit()
	screen_size = get_viewport_rect().size

func _process(delta: float) -> void:
	velocity = Vector2.ZERO
	
	$Hud/BoxLife/VBoxContainer/LabelLife.text = "Vida: " + str(Global.life)
	
	if Global.life <= 0:
		dead = true
		interacting = false
		attacking = false
		$Hud/Information.visible = false
		$Hud/InfoPress.visible = false
		
	if Input.is_action_pressed("move_right") and not $Hud/Information.visible and not dead:
		velocity.x += 1
	if Input.is_action_pressed("move_left") and not $Hud/Information.visible and not dead:
		velocity.x -= 1
	if Input.is_action_pressed("move_down") and not $Hud/Information.visible and not dead:
		velocity.y += 1
	if Input.is_action_pressed("move_up") and not $Hud/Information.visible and not dead:
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
		
		if current_enemy and current_enemy.has_method("take_damage"):
			var attack_direction = (current_enemy.global_position - global_position).normalized()
			current_enemy.take_damage(attack_damage, attack_direction)

	if attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			attacking = false
			$AnimatedSprite2D.stop()
	
	if interacting and Input.is_action_just_pressed("action_e"):
		$Hud/Information.visible = true
		$Hud/InfoPress.visible = false
		
		
	if Input.is_action_just_pressed("curar"): 
		heal()

func heal() -> void:
	var max_life = 100
	if Global.life < max_life:
		print("Curando")
		Global.life += 20  # Valor da cura, ajuste conforme necessário
		Global.life = min(Global.life, max_life)  # Garante que a vida não ultrapassa o máximo
	else:
		print("Vida cheia ou não é possível curar agora")


func _on_totem_pergaminho_body_entered(body: Node2D) -> void:
	if body == self:
		interacting = true
		$Hud/Information/VBoxContainer/Label.text = "Onde o peso da alma não se abate, o caminho será seguro e sem derrota."
		$Hud/Information/VBoxContainer/Button.text = "Fechar"
		if not $Hud/Information/VBoxContainer/Button.is_connected("pressed", _on_button_pressed):
			$Hud/Information/VBoxContainer/Button.connect("pressed", _on_button_pressed)
		$Hud/InfoPress.visible = true


func _on_totem_pergaminho_body_exited(body: Node2D) -> void:
	if body == self:
		interacting = false
		$Hud/InfoPress.visible = false
		$Hud/Information.visible = false
		if $Hud/Information/VBoxContainer/Button.is_connected("pressed", _on_button_pressed):
			$Hud/Information/VBoxContainer/Button.disconnect("pressed", _on_button_pressed)


func _on_button_pressed() -> void:
	$Hud/Information.visible = false

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
		attacking = false
		$Hud/Information.visible = false
		$Hud/InfoPress.visible = false
		print("Morreu")

func _on_area_porta_emit_body_entered(tipo_porta_func) -> void:
	tipo_porta = tipo_porta_func
	interacting = true
	$Hud/Information/VBoxContainer/Label.text = "Deseja abrir a porta e enfrentar as consequências ?"
	$Hud/Information/VBoxContainer/Button.text = "Abrir"
	if not $Hud/Information/VBoxContainer/Button.is_connected("pressed", _on_button_pressed_open_door):
		$Hud/Information/VBoxContainer/Button.connect("pressed", _on_button_pressed_open_door)
	$Hud/InfoPress.visible = true


func _on_area_porta_emit_body_exited() -> void:
	interacting = false
	$Hud/InfoPress.visible = false
	$Hud/Information.visible = false
	if $Hud/Information/VBoxContainer/Button.is_connected("pressed", _on_button_pressed_open_door):
		$Hud/Information/VBoxContainer/Button.disconnect("pressed", _on_button_pressed_open_door)
	
func _on_AnimatedSprite2D_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "dead":
		_on_player_dead()

func _on_player_dead() -> void:
	$Hud/ScreenDead.visible = true

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

func quitGame() -> void:
	restartGameSignal.emit()

func restartGame() -> void:
	quitGameSignal.emit()


func _on_area_2d_body_entered(body) -> void:
	if body.is_in_group("inimigo"):
		current_enemy = body

func _on_chave_coletada():
	$Hud/BoxKey.visible = true
	key = true
	print("Chave coletada!")

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == current_enemy:
		current_enemy = null

func attack():
	if current_enemy and current_enemy.has_method("take_damage"):
		current_enemy.take_damage(attack_damage)
