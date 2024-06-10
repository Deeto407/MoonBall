extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ghosting()

func set_property(tx_pos):
	position = tx_pos

func ghosting():
	var tween_fade = get_tree().create_tween()
	
	tween_fade.tween_property(self, "self_modulate", Color(1, 1, 1, 0), 0.75)
	
	await tween_fade.finished
	
	queue_free()
