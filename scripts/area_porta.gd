extends Area2D

signal emit_body_entered
signal emit_body_exited

@export var tipo_porta = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_body_entered(body):
	if body.is_in_group("Player"):
		emit_body_entered.emit(tipo_porta)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		emit_body_exited.emit()
