extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func new_game():
	get_tree().change_scene_to_file("res://levels/level1.tscn")
	print("Recomeçar")
	$Player.dead = false
	$Player.start($StartPosition.position)
	$Player/ScreenDead.visible = false

func quit():
	print("Sair")
	get_tree().quit()
