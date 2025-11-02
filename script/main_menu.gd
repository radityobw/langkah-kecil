extends Control


## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass


func _on_start_pressed() -> void:
	SelectSfx.play()
	await get_tree().create_timer(0.25).timeout
	get_tree().change_scene_to_file("res://scene/level-select.tscn")



func _on_option_pressed() -> void:
	SelectSfx.play()
	await get_tree().create_timer(0.25).timeout
	get_tree().change_scene_to_file("res://scene/option.tscn")



func _on_exit_pressed() -> void:
	SelectSfx.play()
	await get_tree().create_timer(0.25).timeout
	get_tree().quit()


@onready var fade = $Fade

func _ready() -> void:
	# Pastikan fade di atas dan menutupi layar penuh
	fade.modulate.a = 1.0
	fade.mouse_filter = Control.MOUSE_FILTER_STOP  # tangkap input sementara
	
	# Buat tween fade-in
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 0.0, 1.0)  # durasi 1 detik
	
	await tween.finished
	
	# Setelah fade selesai, pastikan tombol bisa diklik
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE  # lewati input
	fade.visible = false  # opsional, agar hilang sepenuhnya dari layar
