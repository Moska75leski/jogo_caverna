extends CharacterBody2D

@export var speed = 100
@export var detection_range = 200  # Alcance para detectar o jogador
@export var patrol_points = []  # Lista de vetores para os pontos de patrulha

var player = null
var current_patrol_index = 0
var is_chasing_player = false

func _ready() -> void:
	# Definir a RayCast para detectar o jogador
	$RayCast2D.enabled = true
	player = get_node("/root/Level1/Player")  # Certifique-se de ajustar o caminho correto do jogador

func _process(delta: float) -> void:
	if is_chasing_player:
		# Perseguir o jogador
		seek_player(delta)
	else:
		# Patrulhar os pontos
		patrol(delta)
		
	# Detectar o jogador com o RayCast2D
	check_for_player()

# Função para patrulhar entre os pontos
func patrol(delta: float) -> void:
	var target = patrol_points[current_patrol_index]
	move_towards(target, delta)
	
	# Checa se chegou no ponto de patrulha
	if position.distance_to(target) < 10:
		current_patrol_index = (current_patrol_index + 1) % patrol_points.size()

# Função para perseguir o jogador
func seek_player(delta: float) -> void:
	var direction = (player.position - position).normalized()
	velocity = direction * speed
	move_and_slide()

# Função para mover o inimigo em direção a um ponto
func move_towards(target: Vector2, delta: float) -> void:
	var direction = (target - position).normalized()
	velocity = direction * speed
	move_and_slide()

# Função para verificar se o jogador está no alcance do RayCast2D
func check_for_player() -> void:
	if $RayCast2D.is_colliding() and $RayCast2D.get_collider() == player:
		is_chasing_player = true
	else:
		is_chasing_player = false
