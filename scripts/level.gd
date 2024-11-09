extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if $AreaPorta and $AreaPorta.is_in_group("area-porta-mini-boss"):
		$AreaPorta.monitoring = false

func new_game():
	get_tree().change_scene_to_file("res://scenes/level_1.tscn")
	print("Recomeçar")
	$Player.dead = false
	$Player.start($StartPosition.position)
	$Player/Hud/ScreenDead.visible = false
	Global.life = 100

func quit():
	print("Sair")
	get_tree().quit()


func _on_player_start_position() -> void:
	$Player.start($StartPosition.position)

func _on_mini_boss_defeated() -> void:
	$AreaPorta.monitoring = true

func _on_area_porta_emit_body_entered() -> void:
	pass # Replace with function body.


func _on_demonio_labirinto_boss_final_defeated() -> void:
	$Player/Hud/ScreenVictory.visible = true
