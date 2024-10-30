extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func new_game():
	get_tree().change_scene_to_file("res://levels/level1.tscn")
	get_tree().reload_current_scene()
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


func _on_area_porta_emit_body_entered() -> void:
	pass # Replace with function body.
