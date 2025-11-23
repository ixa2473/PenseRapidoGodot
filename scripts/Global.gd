extends Node

const VERSION = "1.00"

enum GameMode { MATH, LANGUAGE }
enum Difficulty { FACIL, MEDIO, DIFICIL }

var current_mode: GameMode = GameMode.MATH

var current_difficulty: Difficulty = Difficulty.FACIL
var lives: int = 3
var score: int = 0
var correct_answers: int = 0
var questions_answered: int = 0
var total_questions: int = 0
var victory: bool = false

var sound_enabled: bool = true
var music_enabled: bool = true

var highscore_manager: Node

const DIFFICULTY_SETTINGS = {
	Difficulty.FACIL: {
		"name": "FÁCIL",
		"lives": 3,
		"growth_time": 8.0,
		"age_range": "6-7"
	},
	Difficulty.MEDIO: {
		"name": "MÉDIO",
		"lives": 3,
		"growth_time": 6.0,
		"age_range": "7-8"
	},
	Difficulty.DIFICIL: {
		"name": "DIFÍCIL",
		"lives": 3,
		"growth_time": 4.0,
		"age_range": "9"
	}
}

const SAVE_PATH = "user://pense_rapido_save.cfg"

var menu_music_player: AudioStreamPlayer
var gameplay_music_player: AudioStreamPlayer
var current_music: AudioStreamPlayer

func _ready() -> void:
	print("<Global> script initiated")
	load_game()

	if not menu_music_player:
		menu_music_player = AudioStreamPlayer.new()
		menu_music_player.stream = load("res://assets/audio/menu-music.mp3")
		menu_music_player.name = "MenuMusicPlayer"
		add_child(menu_music_player)

	if not gameplay_music_player:
		gameplay_music_player = AudioStreamPlayer.new()
		gameplay_music_player.stream = load("res://assets/audio/gameplay-music.mp3")
		gameplay_music_player.name = "GameplayMusicPlayer"
		add_child(gameplay_music_player)

	highscore_manager = load("res://scripts/HighScore.gd").new()
	add_child(highscore_manager)

	get_tree().scene_changed.connect(on_scene_changed)
	play_music(menu_music_player)


func start_game(mode: GameMode, difficulty: Difficulty) -> void:
	current_mode = mode
	current_difficulty = difficulty
	lives = DIFFICULTY_SETTINGS[difficulty]["lives"]
	score = 0
	correct_answers = 0
	questions_answered = 0
	total_questions = 0
	victory = false

func get_difficulty_settings() -> Dictionary:
	return DIFFICULTY_SETTINGS[current_difficulty]

func get_difficulty_name(difficulty: Difficulty = current_difficulty) -> String:
	return DIFFICULTY_SETTINGS[difficulty]["name"]

func get_mode_name(mode: GameMode = current_mode) -> String:
	return "Matemática" if mode == GameMode.MATH else "Português"

func check_defeat() -> bool:
	return lives <= 0

func lose_life() -> void:
	lives = max(0, lives - 1)

func add_score(points: int) -> void:
	score += points
	correct_answers += 1

func get_high_score_key() -> String:
	var mode_str = "math" if current_mode == GameMode.MATH else "language"
	var diff_str = get_difficulty_name().to_lower()
	return mode_str + "_" + diff_str

func save_game() -> void:
	var config = ConfigFile.new()

	config.set_value("Settings", "sound_enabled", sound_enabled)
	config.set_value("Settings", "music_enabled", music_enabled)

	config.save(SAVE_PATH)

func load_game() -> void:
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)

	if err != OK:
		return

	if config.has_section_key("Settings", "sound_enabled"):
		sound_enabled = config.get_value("Settings", "sound_enabled")
	if config.has_section_key("Settings", "music_enabled"):
		music_enabled = config.get_value("Settings", "music_enabled")

func change_scene(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)

func on_scene_changed() -> void:
	var scene_path = get_tree().current_scene.scene_file_path
	if scene_path.to_lower() == "res://scenes/gameplay.tscn":
		play_music(gameplay_music_player)
	else:
		play_music(menu_music_player)

func play_music(music_player: AudioStreamPlayer) -> void:
	if music_enabled and current_music != music_player:
		if current_music:
			current_music.stop()
		current_music = music_player
		current_music.play()

func stop_music() -> void:
	if current_music:
		current_music.stop()

func is_audio_enabled() -> bool:
	return sound_enabled and music_enabled

func toggle_audio() -> void:
	sound_enabled = not sound_enabled
	music_enabled = not music_enabled
	if music_enabled:
		play_music(current_music)
	else:
		stop_music()
	save_game()
