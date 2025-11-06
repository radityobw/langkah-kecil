extends Control



func _on_backlv1_pressed() -> void:
	SelectSfx.play()
	await get_tree().create_timer(0.25).timeout
	get_tree().change_scene_to_file("res://scene/level-select.tscn")
