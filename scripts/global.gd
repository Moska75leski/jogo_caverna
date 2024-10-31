extends Node

var life = 100
var max_life = 100
var regen_rate = 1 # quantidade de vida regenerada por ciclo
var regen_interval = 2.0 # intervalo de tempo entre regenerações em segundos
var regen_timer = 0.0

var music_player: AudioStreamPlayer

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.stream = preload("res://assets/musica/cave-temple-atmo-orchestral-drone-thriller-9357.mp3")
	music_player.volume_db = -5  # Ajuste o volume se necessário
	music_player.play()
	if music_player.stream:
		music_player.stream.loop = true

func _process(delta: float) -> void:
	if life > 0:
		tick_life_restart(delta)
	else:
		life = 0

func tick_life_restart(delta: float) -> void:
	if life < max_life:
		regen_timer += delta
		if regen_timer >= regen_interval:
			life = min(life + regen_rate, max_life)
			regen_timer = 0.0
