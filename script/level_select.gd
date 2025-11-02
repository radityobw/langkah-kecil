extends Control


func lv1_on_pressed() -> void:
	SelectSfx.play()
	await get_tree().create_timer(0.25).timeout


func lv2_on_pressed() -> void:
	SelectSfx.play()
	await get_tree().create_timer(0.25).timeout


func _on_home_pressed() -> void:
	SelectSfx.play()
	await get_tree().create_timer(0.25).timeout
	get_tree().change_scene_to_file("res://scene/main-menu.tscn")
