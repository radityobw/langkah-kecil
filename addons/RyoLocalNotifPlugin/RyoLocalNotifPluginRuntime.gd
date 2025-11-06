#extends Node
#class_name RyoLocalNotifPluginRuntime
#
## Mengirim notifikasi instan
#func send_notification(title: String, message: String):
	#if Engine.has_singleton("RyoLocalNotifPlugin"):
		#Engine.get_singleton("RyoLocalNotifPlugin").sendNotification(title, message)
#
## Menjadwalkan notifikasi pada waktu tertentu (jam, menit)
#func schedule_notification(hour: int, minute: int, title: String, message: String):
	#if Engine.has_singleton("RyoLocalNotifPlugin"):
		#Engine.get_singleton("RyoLocalNotifPlugin").scheduleNotification(hour, minute, title, message)

extends Node
class_name RyoLocalNotifPluginRuntime

# Kirim notifikasi langsung
func send_notification(title: String, text: String) -> void:
	if Engine.has_singleton("GodotAndroidNotifications"):
		var notif = Engine.get_singleton("GodotAndroidNotifications")
		notif.show_notification(title, text, true, true)
	else:
		print("⚠️ Notifikasi tidak tersedia (bukan Android atau plugin tidak aktif).")

# Jadwalkan notifikasi (misal jam 20:00 waktu lokal)
func schedule_notification(hour: int, minute: int, title: String, text: String) -> void:
	if Engine.has_singleton("GodotAndroidNotifications"):
		var notif = Engine.get_singleton("GodotAndroidNotifications")

		var time = Engine.get_main_loop().get_time() # ✅ akses instance waktu yang benar di Godot 4.5
		var now = time.get_datetime_dict_from_system()

		var target_time = time.get_unix_time_from_datetime({
			"year": now["year"],
			"month": now["month"],
			"day": now["day"],
			"hour": hour,
			"minute": minute,
			"second": 0
		})

		var current_unix = time.get_unix_time_from_system()

		if target_time <= current_unix:
			target_time += 86400 # tambah 1 hari (detik)

		var delay = target_time - current_unix
		notif.schedule_notification(title, text, delay, true, true)
	else:
		print("⚠️ Jadwal notifikasi gagal — plugin Android tidak aktif.")
