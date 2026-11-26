extends Control

@onready var fade = $Fade

var _logo_pivot: Node3D = null
var _logo_time: float = 0.0
var _pointer_offset := Vector2.ZERO


func _ready() -> void:
	_setup_3d_logo()

	# --- Efek Fade In pada saat scene dimulai ---
	fade.modulate.a = 1.0
	fade.mouse_filter = Control.MOUSE_FILTER_STOP  # tangkap input sementara

	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 0.0, 1.0)  # durasi 1 detik
	await tween.finished

	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE  # izinkan input
	fade.visible = false  # opsional, sembunyikan fade sepenuhnya


func _input(event: InputEvent) -> void:
	if _logo_pivot == null:
		return
	if event is InputEventMouseMotion:
		var vp_size := get_viewport_rect().size
		if vp_size.x > 0.0 and vp_size.y > 0.0:
			var nx := clampf((event.position.x / vp_size.x - 0.5) * 2.0, -1.0, 1.0)
			var ny := clampf((event.position.y / vp_size.y - 0.5) * 2.0, -1.0, 1.0)
			_pointer_offset = Vector2(nx, ny)


func _process(delta: float) -> void:
	if _logo_pivot == null:
		return
	_logo_time += delta
	var target_yaw := sin(_logo_time * 1.35) * 0.16 + _pointer_offset.x * 0.14
	var target_pitch := sin(_logo_time * 0.9) * 0.05 + _pointer_offset.y * 0.08
	_logo_pivot.rotation.y = lerpf(_logo_pivot.rotation.y, target_yaw, minf(1.0, delta * 6.0))
	_logo_pivot.rotation.x = lerpf(_logo_pivot.rotation.x, target_pitch, minf(1.0, delta * 6.0))
	_logo_pivot.position.y = sin(_logo_time * 1.8) * 0.035


func _collect_mesh_aabb(node: Node, parent_xform: Transform3D, bounds: Array) -> void:
	var local_xform := parent_xform
	if node is Node3D:
		local_xform = parent_xform * (node as Node3D).transform
	if node is MeshInstance3D:
		var mi := node as MeshInstance3D
		if mi.mesh != null:
			var local_box := local_xform * mi.mesh.get_aabb()
			if bounds.is_empty():
				bounds.append(local_box)
			else:
				bounds[0] = (bounds[0] as AABB).merge(local_box)
	for child in node.get_children():
		_collect_mesh_aabb(child, local_xform, bounds)


func _setup_3d_logo() -> void:
	if DisplayServer.get_name() == "headless":
		return
	const GLB_PATH := "res://assets/models/langkah-kecil.glb"
	if not FileAccess.file_exists(GLB_PATH):
		return

	var bytes := FileAccess.get_file_as_bytes(GLB_PATH)
	if bytes.is_empty():
		return

	var doc := GLTFDocument.new()
	var state := GLTFState.new()
	if doc.append_from_buffer(bytes, "", state) != OK:
		return

	var model_root := doc.generate_scene(state)
	if model_root == null:
		return

	var bounds: Array = []
	_collect_mesh_aabb(model_root, Transform3D.IDENTITY, bounds)
	if bounds.is_empty():
		model_root.free()
		return

	var aabb := bounds[0] as AABB
	var max_dim := maxf(aabb.size.x, maxf(aabb.size.y, aabb.size.z))
	if max_dim <= 0.0001:
		model_root.free()
		return

	var svc := SubViewportContainer.new()
	svc.name = "Logo3DViewport"
	svc.stretch = true
	svc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	svc.set_anchors_preset(Control.PRESET_CENTER)
	svc.offset_left = -420.0
	svc.offset_top = -430.0
	svc.offset_right = 420.0
	svc.offset_bottom = -10.0

	var vp := SubViewport.new()
	vp.own_world_3d = true
	vp.transparent_bg = true
	vp.msaa_3d = Viewport.MSAA_4X
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	svc.add_child(vp)

	var env := Environment.new()
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(1.0, 0.96, 0.94, 1.0)
	env.ambient_light_energy = 1.05
	var world_env := WorldEnvironment.new()
	world_env.environment = env
	vp.add_child(world_env)

	var cam := Camera3D.new()
	cam.fov = 30.0
	cam.position = Vector3(0.0, 0.0, 4.1)
	vp.add_child(cam)

	var key := DirectionalLight3D.new()
	key.light_color = Color(1.0, 0.97, 0.92, 1.0)
	key.light_energy = 1.35
	key.rotation_degrees = Vector3(-32.0, 28.0, 0.0)
	vp.add_child(key)

	var rim := DirectionalLight3D.new()
	rim.light_color = Color(1.0, 0.52, 0.72, 1.0)
	rim.light_energy = 0.75
	rim.rotation_degrees = Vector3(20.0, -145.0, 0.0)
	vp.add_child(rim)

	_logo_pivot = Node3D.new()
	vp.add_child(_logo_pivot)

	var upright := Node3D.new()
	upright.rotation.x = PI * 0.5
	var norm_scale := 2.35 / max_dim
	upright.scale = Vector3.ONE * norm_scale
	model_root.position = -aabb.get_center()
	upright.add_child(model_root)
	_logo_pivot.add_child(upright)

	add_child(svc)
	var fade_idx := fade.get_index()
	move_child(svc, maxi(0, fade_idx))

	if has_node("Panel2"):
		$Panel2.visible = false


# --- Fungsi tombol Start ---
func _on_start_pressed() -> void:
	SelectSfx.play()
	await get_tree().create_timer(0.25).timeout
	get_tree().change_scene_to_file("res://scene/level-select.tscn")


# --- Fungsi tombol Option ---
func _on_option_pressed() -> void:
	SelectSfx.play()
	await get_tree().create_timer(0.25).timeout
	get_tree().change_scene_to_file("res://scene/option.tscn")


# --- Fungsi tombol Exit ---
func _on_exit_pressed() -> void:
	SelectSfx.play()
	await get_tree().create_timer(0.25).timeout
	get_tree().quit()
