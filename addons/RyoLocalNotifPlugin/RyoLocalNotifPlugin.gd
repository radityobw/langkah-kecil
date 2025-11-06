#@tool
#extends EditorPlugin
#
#func _enter_tree():
	#add_autoload_singleton("RyoLocalNotifPlugin", "res://addons/RyoLocalNotifPlugin/RyoLocalNotifPluginRuntime.gd")
#
#func _exit_tree():
	#remove_autoload_singleton("RyoLocalNotifPlugin")

@tool
extends EditorPlugin

func _enter_tree():
	add_autoload_singleton("RyoLocalNotifPluginRuntime", "res://addons/RyoLocalNotifPlugin/RyoLocalNotifPluginRuntime.gd")
	print("✅ RyoLocalNotifPlugin loaded")

func _exit_tree():
	remove_autoload_singleton("RyoLocalNotifPluginRuntime")
	print("❌ RyoLocalNotifPlugin unloaded")
