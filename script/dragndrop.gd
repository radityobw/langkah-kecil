extends TextureRect
#
#func _get_drag_data(_at_position):
	#if texture == null:
		#return null  # Tidak bisa drag kalau slot kosong
#
		## Mainkan SFX saat mulai drag
	#SelectSfx.play()
	#
	## Buat tampilan preview (ghost image) saat drag
	#var preview_texture = TextureRect.new()
	#preview_texture.texture = texture
	#preview_texture.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	#preview_texture.size = Vector2(181, 190)
#
	#var preview = Control.new()
	#preview.add_child(preview_texture)
	#set_drag_preview(preview)
#
	## Kirim data yang dibawa saat drag
	#var data = {
		#"texture": texture,
		#"source": self
	#}
	#return data
#
#
#func _can_drop_data(_pos, data):
	#return typeof(data) == TYPE_DICTIONARY and data.has("texture")
	#
#
#func _drop_data(_pos, data):
		## Mainkan SFX saat berhasil drop
	#SelectSfx.play()
	#
	## Ambil tekstur dari sumber dan taruh di slot ini
	#texture = data["texture"]
#
	## Hapus dari sumber (pindah, bukan copy)
	#data["source"].texture = null
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
##extends TextureRect
##
##
##func _get_drag_data(_at_position):
	##
	##var preview_texture = TextureRect.new()
	##
	##preview_texture.texture = texture
	##preview_texture.expand_mode = 1
	##preview_texture.size = Vector2(181,190)
	##
	##var preview = Control.new()
	##preview.add_child(preview_texture)
	##
	##set_drag_preview(preview)
	##texture = null
	##
	##return preview_texture.texture
##
##func _can_drop_data(_pos, data):
	##return data is Texture2D
##
##func _drop_data(_pos, data):
	##texture = data
