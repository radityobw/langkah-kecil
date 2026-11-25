extends TextureRect
## Drag-and-drop schedule slot with persistent ConfigFile autosave across slots.


func _ready() -> void:
	_load_inventory()


## Starts drag operation when slot holds a texture and creates visual drag preview.
func _get_drag_data(_at_position: Vector2) -> Variant:
	if texture == null:
		return null

	SelectSfx.play()

	var preview_texture := TextureRect.new()
	preview_texture.texture = texture
	preview_texture.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	preview_texture.position = Vector2(-100, -100)
	preview_texture.size = Vector2(181, 190)

	var preview := Control.new()
	preview.add_child(preview_texture)
	set_drag_preview(preview)

	var data := {
		"texture": texture,
		"source": self
	}
	return data


## Accepts drop data from another TextureRect slot carrying a texture dictionary.
func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	return typeof(data) == TYPE_DICTIONARY and data.has("texture") and data["source"] != self


## Swaps slot textures on drop and persists the updated layout.
func _drop_data(_pos: Vector2, data: Variant) -> void:
	if typeof(data) == TYPE_DICTIONARY and data.has("texture"):
		if data["source"] == self:
			return

		SelectSfx.play()

		var temp_tex: Texture2D = texture
		texture = data["texture"]
		data["source"].texture = temp_tex

		_autosave_inventory()


func _autosave_inventory() -> void:
	var config := ConfigFile.new()
	var root: Node = get_tree().root.get_node(".")
	var all_slots: Array = _get_all_slots(root)

	for slot in all_slots:
		var tex_path := ""
		if slot.texture and slot.texture.resource_path != "":
			tex_path = slot.texture.resource_path
		config.set_value("inventory", slot.name, tex_path)

	config.save("user://inventory.cfg")


func _load_inventory() -> void:
	var config := ConfigFile.new()
	var err: Error = config.load("user://inventory.cfg")
	if err != OK:
		return

	var root: Node = get_tree().root.get_node(".")
	var all_slots: Array = _get_all_slots(root)

	for slot in all_slots:
		var tex_path: String = config.get_value("inventory", slot.name, "")
		if tex_path != "":
			slot.texture = load(tex_path)
		else:
			slot.texture = null


func _get_all_slots(root: Node) -> Array:
	var slots: Array = []
	for child in root.get_children():
		if child is TextureRect:
			slots.append(child)
		elif child.get_child_count() > 0:
			slots += _get_all_slots(child)
	return slots
