extends Node

const HIGHSCORE_FILE = "user://highscores.json"
var highscores = []

func _ready():
	load_highscores()

func load_highscores():
	if not FileAccess.file_exists(HIGHSCORE_FILE):
		return

	var file = FileAccess.open(HIGHSCORE_FILE, FileAccess.READ)
	var content = file.get_as_text()
	if content:
		highscores = JSON.parse_string(content)
	file.close()

func save_highscores():
	var file = FileAccess.open(HIGHSCORE_FILE, FileAccess.WRITE)
	file.store_string(JSON.stringify(highscores, "\t"))
	file.close()

func add_highscore(player_name, score):
	highscores.append({"name": player_name, "score": score})
	highscores.sort_custom(Callable(self, "sort_by_score"))
	save_highscores()

func get_top_highscores(count):
	return highscores.slice(0, count)

func sort_by_score(a, b):
	return a["score"] > b["score"]