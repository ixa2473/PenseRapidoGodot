extends Control

@onready var result_label: Label = $VBoxContainer/ResultLabel
@onready var score_label: Label = $VBoxContainer/ScoreLabel
@onready var phases_label: Label = $VBoxContainer/PhasesLabel
@onready var accuracy_label: Label = $VBoxContainer/AccuracyLabel
@onready var high_score_label: Label = $VBoxContainer/HighScoreLabel
@onready var instructions_container: HBoxContainer = $VBoxContainer/InstructionsContainer

var is_victory: bool = false
var is_new_high_score: bool = false

func _ready() -> void:
	determine_result()
	display_stats()

func _input(event: InputEvent) -> void:
	var viewport = get_viewport()
	if not viewport:
		return
	
	if event.is_action_pressed("ui_accept"):
		# Handle input before scene change to avoid null viewport
		viewport.set_input_as_handled()
		play_again()
	elif event.is_action_pressed("Back"):
		# Handle input before scene change to avoid null viewport
		viewport.set_input_as_handled()
		go_to_menu()

func determine_result() -> void:
	is_victory = Global.check_victory()
	is_new_high_score = Global.score > Global.get_current_high_score()
	
	if is_victory:
		result_label.text = "VITÓRIA!"
		result_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))
		# TODO: Play victory sound
	else:
		result_label.text = "DERROTA!"
		result_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
		# TODO: Play defeat sound

func display_stats() -> void:
	score_label.text = "Pontuação: " + str(Global.score)
	
	var settings = Global.get_difficulty_settings()
	var total_phases = settings["phases"]
	phases_label.text = "Fases Completadas: " + str(Global.current_phase) + "/" + str(total_phases)
	
	# Calculate accuracy (assuming questions per phase)
	var questions_per_phase = settings["questions_per_phase"]
	var total_expected = Global.current_phase * questions_per_phase
	var accuracy = 0.0
	if total_expected > 0:
		accuracy = (float(Global.correct_answers) / float(total_expected)) * 100.0
	accuracy_label.text = "Precisão: %.1f%%" % accuracy
	
	# High score display
	if is_new_high_score:
		high_score_label.text = "NOVO RECORDE!"
		high_score_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
		high_score_label.visible = true
	else:
		var current_high = Global.get_current_high_score()
		if current_high > 0:
			high_score_label.text = "Recorde: " + str(current_high)
			high_score_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
			high_score_label.visible = true
		else:
			high_score_label.visible = false

func play_again() -> void:
	# Restart with same mode and difficulty
	Global.start_game(Global.current_mode, Global.current_difficulty)
	Global.change_scene("res://scenes/Gameplay.tscn")

func go_to_menu() -> void:
	Global.change_scene("res://scenes/MainMenu.tscn")
