extends SceneTree
## Headless smoke test verifying all scenes instantiate cleanly and all scripts compile.


func _collect_files(dir_path: String, ext: String) -> Array[String]:
	var results: Array[String] = []
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return results
	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if not entry.begins_with("."):
			var full_path := dir_path.path_join(entry)
			if dir.current_is_dir():
				results.append_array(_collect_files(full_path, ext))
			elif entry.ends_with(ext):
				results.append(full_path)
		entry = dir.get_next()
	dir.list_dir_end()
	results.sort()
	return results


func _initialize() -> void:
	var failures := 0
	var scenes := _collect_files("res://scene", ".tscn")
	var scripts := _collect_files("res://script", ".gd")

	for scene_path in scenes:
		var res := load(scene_path)
		if res == null or not (res is PackedScene):
			printerr("[FAIL] Failed to load PackedScene: ", scene_path)
			failures += 1
			continue
		var instance := (res as PackedScene).instantiate()
		if instance == null:
			printerr("[FAIL] Failed to instantiate scene: ", scene_path)
			failures += 1
			continue
		instance.free()

	for script_path in scripts:
		var scr := load(script_path)
		if scr == null or not (scr is GDScript):
			printerr("[FAIL] Failed to load GDScript: ", script_path)
			failures += 1
			continue
		if not (scr as GDScript).can_instantiate():
			printerr("[FAIL] Script failed compilation/instantiation check: ", script_path)
			failures += 1

	print("Smoke test summary: scenes=%d, scripts=%d, failures=%d" % [scenes.size(), scripts.size(), failures])
	quit(1 if failures > 0 else 0)
