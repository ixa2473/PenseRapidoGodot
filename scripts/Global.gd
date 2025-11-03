extends Node

# Game version
const VERSION = "1.00"

# Game state enums
enum GameMode { MATH, LANGUAGE }
enum Difficulty { FACIL, MEDIO, DIFICIL }

# Current game state
var current_mode: GameMode = GameMode.MATH
var current_difficulty: Difficulty = Difficulty.FACIL
var current_phase: int = 0
var lives: int = 3
var score: int = 0
var correct_answers: int = 0

# Settings
var sound_enabled: bool = true
var music_enabled: bool = true

# High scores (stored per mode and difficulty)
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

# Save file path
const SAVE_PATH = "user://pense_rapido_save.cfg"

func _ready() -> void:
	load_game()

# Start a new game with selected mode and difficulty
func start_game(mode: GameMode, difficulty: Difficulty) -> void:
	current_mode = mode
	current_difficulty = difficulty
	current_phase = 0
	lives = DIFFICULTY_SETTINGS[difficulty]["lives"]
	score = 0
	correct_answers = 0

# Get current difficulty settings
func get_difficulty_settings() -> Dictionary:
	return DIFFICULTY_SETTINGS[current_difficulty]

# Get difficulty name string
func get_difficulty_name(difficulty: Difficulty = current_difficulty) -> String:
	return DIFFICULTY_SETTINGS[difficulty]["name"]

# Get mode name string
func get_mode_name(mode: GameMode = current_mode) -> String:
	return "Matemática" if mode == GameMode.MATH else "Português"

# Check if player has won
func check_victory() -> bool:
	var settings = get_difficulty_settings()
	return current_phase >= settings["phases"] and lives > 0

# Check if player has lost
func check_defeat() -> bool:
	return lives <= 0

# Lose a life
func lose_life() -> void:
	lives = max(0, lives - 1)

# Advance to next phase
func advance_phase() -> void:
	current_phase += 1

# Add score
func add_score(points: int) -> void:
	score += points
	correct_answers += 1

# Get high score key
func get_high_score_key() -> String:
	var mode_str = "math" if current_mode == GameMode.MATH else "language"
	var diff_str = get_difficulty_name().to_lower()
	return mode_str + "_" + diff_str

# Check and update high score
func update_high_score() -> bool:
	var key = get_high_score_key()
	if score > high_scores.get(key, 0):
		high_scores[key] = score
		save_game()
		return true
	return false

# Get current high score
func get_current_high_score() -> int:
	var key = get_high_score_key()
	return high_scores.get(key, 0)

# Save game data
func save_game() -> void:
	var config = ConfigFile.new()
	
	# Save high scores
	for key in high_scores.keys():
		config.set_value("HighScores", key, high_scores[key])
	
	# Save settings
	config.set_value("Settings", "sound_enabled", sound_enabled)
	config.set_value("Settings", "music_enabled", music_enabled)
	
	config.save(SAVE_PATH)

# Load game data
func load_game() -> void:
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	
	if err != OK:
		# No save file exists, use defaults
		return
	
	# Load high scores
	for key in high_scores.keys():
		if config.has_section_key("HighScores", key):
			high_scores[key] = config.get_value("HighScores", key)
	
	# Load settings
	if config.has_section_key("Settings", "sound_enabled"):
		sound_enabled = config.get_value("Settings", "sound_enabled")
	if config.has_section_key("Settings", "music_enabled"):
		music_enabled = config.get_value("Settings", "music_enabled")

# Scene transition helper
func change_scene(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)

