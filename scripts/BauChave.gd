extends Area2D

signal chave_coletada

func _ready() -> void:
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		emit_signal("chave_coletada")
		queue_free()
