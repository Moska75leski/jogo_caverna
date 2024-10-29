extends Node

var life = 100
var max_life = 100
var regen_rate = 1 # quantidade de vida regenerada por ciclo
var regen_interval = 2.0 # intervalo de tempo entre regenerações em segundos
var regen_timer = 0.0

func _process(delta: float) -> void:
	tick_life_restart(delta)

func tick_life_restart(delta: float) -> void:
	if life < max_life:
		regen_timer += delta
		if regen_timer >= regen_interval:
			life = min(life + regen_rate, max_life)
			regen_timer = 0.0
