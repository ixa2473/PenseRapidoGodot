extends Node

const VERSION = "1.00"

enum GameMode { MATH, LANGUAGE }
enum Difficulty { FACIL, MEDIO, DIFICIL }

var current_mode: GameMode = GameMode.MATH
var current_difficulty: Difficulty = Difficulty.FACIL
var current_phase: int = 0
var lives: int = 3
var score: int = 0
var correct_answers: int = 0

var sound_enabled: bool = true
var music_enabled: bool = true

var high_scores: Dictionary = {
	"math_facil": 0,
	"math_medio": 0,
	"math_dificil": 0,
	"language_facil": 0,
	"language_medio": 0,
	"language_dificil": 0
}

# Difficulty constants
const DIFFICULTY_SETTINGS = {
	Difficulty.FACIL: {
		"name": "FÁCIL",
		"phases": 7,
		"lives": 3,
		"growth_time": 8.0,
		"age_range": "6-7",
		"questions_per_phase": 3
	},
	Difficulty.MEDIO: {
		"name": "MÉDIO",
		"phases": 7,
		"lives": 3,
		"growth_time": 6.0,
		"age_range": "7-8",
		"questions_per_phase": 4
	},
	Difficulty.DIFICIL: {
		"name": "DIFÍCIL",
		"phases": 7,
		"lives": 3,
		"growth_time": 4.0,
		"age_range": "9",
		"questions_per_phase": 5
	}
}

const SAVE_PATH = "user://pense_rapido_save.cfg"

var menu_music_player: AudioStreamPlayer
var gameplay_music_player: AudioStreamPlayer

func _ready() -> void:
	load_game()

	menu_music_player = AudioStreamPlayer.new()
	menu_music_player.stream = load("res://assets/audio/menu-music.mp3")
	menu_music_player.name = "MenuMusicPlayer"
	add_child(menu_music_player)

	gameplay_music_player = AudioStreamPlayer.new()
	gameplay_music_player.stream = load("res://assets/audio/gameplay-music.mp3")
	gameplay_music_player.name = "GameplayMusicPlayer"
	add_child(gameplay_music_player)

	get_tree().scene_changed.connect(on_scene_changed)


func start_game(mode: GameMode, difficulty: Difficulty) -> void:
	current_mode = mode
	current_difficulty = difficulty
	current_phase = 0
	lives = DIFFICULTY_SETTINGS[difficulty]["lives"]
	score = 0
	correct_answers = 0

func get_difficulty_settings() -> Dictionary:
	return DIFFICULTY_SETTINGS[current_difficulty]

func get_difficulty_name(difficulty: Difficulty = current_difficulty) -> String:
	return DIFFICULTY_SETTINGS[difficulty]["name"]

func get_mode_name(mode: GameMode = current_mode) -> String:
	return "Matemática" if mode == GameMode.MATH else "Português"

func check_victory() -> bool:
	var settings = get_difficulty_settings()
	return current_phase >= settings["phases"] and lives > 0

func check_defeat() -> bool:
	return lives <= 0

func lose_life() -> void:
	lives = max(0, lives - 1)

func advance_phase() -> void:
	current_phase += 1

func add_score(points: int) -> void:
	score += points
	correct_answers += 1

func get_high_score_key() -> String:
	var mode_str = "math" if current_mode == GameMode.MATH else "language"
	var diff_str = get_difficulty_name().to_lower()
	return mode_str + "_" + diff_str

func update_high_score() -> bool:
	var key = get_high_score_key()
	if score > high_scores.get(key, 0):
		high_scores[key] = score
		save_game()
		return true
	return false

func get_current_high_score() -> int:
	var key = get_high_score_key()
	return high_scores.get(key, 0)

func save_game() -> void:
	var config = ConfigFile.new()

	for key in high_scores.keys():
		config.set_value("HighScores", key, high_scores[key])

	config.set_value("Settings", "sound_enabled", sound_enabled)
	config.set_value("Settings", "music_enabled", music_enabled)

	config.save(SAVE_PATH)

func load_game() -> void:
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)

	if err != OK:
		return

	for key in high_scores.keys():
		if config.has_section_key("HighScores", key):
			high_scores[key] = config.get_value("HighScores", key)

	if config.has_section_key("Settings", "sound_enabled"):
		sound_enabled = config.get_value("Settings", "sound_enabled")
	if config.has_section_key("Settings", "music_enabled"):
		music_enabled = config.get_value("Settings", "music_enabled")

func change_scene(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)

func on_scene_changed(new_scene: Node) -> void:
	var scene_path = new_scene.scene_file_path

	if scene_path.to_lower() == "res://scenes/gameplay.tscn":
		stop_menu_music()
		play_gameplay_music()
	else:
		stop_gameplay_music()
		play_menu_music()

func play_menu_music() -> void:
	if music_enabled and not menu_music_player.playing:
		menu_music_player.play()

func stop_menu_music() -> void:
	if menu_music_player.playing:
		menu_music_player.stop()

func play_gameplay_music() -> void:
	if music_enabled and not gameplay_music_player.playing:
		gameplay_music_player.play()

func stop_gameplay_music() -> void:
	if gameplay_music_player.playing:
		gameplay_music_player.stop()
