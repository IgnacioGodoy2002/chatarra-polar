extends Node

const SAVE_PATH: String = "user://chatarra_polar_save.json"


func save_game(data: Dictionary) -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	if file == null:
		print("No se pudo guardar la partida")
		return

	var json_text := JSON.stringify(data)
	file.store_string(json_text)
	file.close()

	print("Partida guardada")


func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		print("No hay partida guardada")
		return {}

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)

	if file == null:
		print("No se pudo cargar la partida")
		return {}

	var json_text := file.get_as_text()
	file.close()

	var json := JSON.new()
	var result := json.parse(json_text)

	if result != OK:
		print("Error leyendo el guardado")
		return {}

	var data = json.data

	if typeof(data) != TYPE_DICTIONARY:
		return {}

	print("Partida cargada")
	return data


func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
		print("Partida borrada")
