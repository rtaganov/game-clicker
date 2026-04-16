extends Node

const SAVE_PATH := "user://progress.save"

func save_progress(progress: PlayerProgress) -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Не удалось открыть файл сохранения")
		return
	file.store_string(JSON.stringify(progress.to_dict()))

func load_progress() -> PlayerProgress:
	var progress := PlayerProgress.new()
	if not FileAccess.file_exists(SAVE_PATH):
		return progress
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return progress
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		progress.from_dict(parsed)
	return progress
