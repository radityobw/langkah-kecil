extends AudioStreamPlayer2D

#@onready var music = $AudioStreamPlayer2D

#func _ready():
	#Backsound.play()
	#Backsound.finished.connect(_on_music_finished)

func _on_music_finished():
	Backsound.play()  # mulai lagi dari awal
