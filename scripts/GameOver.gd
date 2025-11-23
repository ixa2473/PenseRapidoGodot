extends Control

@onready var result_label: Label = $VBoxContainer/ResultLabel
@onready var score_label: Label = $VBoxContainer/ScoreLabel
@onready var phases_label: Label = $VBoxContainer/PhasesLabel
@onready var accuracy_label: Label = $VBoxContainer/AccuracyLabel
@onready var high_score_label: Label = $VBoxContainer/HighScoreLabel
@onready var instructions_container: HBoxContainer = $VBoxContainer/InstructionsContainer
@onready var name_edit: LineEdit = $VBoxContainer/NameEdit
@onready var save_button: Button = $VBoxContainer/SaveButton
@onready var highscore_list: VBoxContainer = $VBoxContainer/HighscoreList

var is_victory: bool = false
var is_new_high_score: bool = false

func _ready() -> void:
	print("<Game Over> script initiated")
	determine_result()
	display_stats()
	display_highscores()

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
	is_victory = Global.victory
	var highscores = Global.highscore_manager.get_top_highscores(1)
	if highscores.size() > 0:
		is_new_high_score = Global.score > highscores[0]["score"]
	else:
		is_new_high_score = true

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
	phases_label.text = "Fases Completadas: " + str(Global.questions_answered) + "/" + str(Global.total_questions)

	# Calculate accuracy
	var accuracy = 0.0
	if Global.total_questions > 0:
		accuracy = (float(Global.correct_answers) / float(Global.total_questions)) * 100.0
		accuracy_label.text = "Precisão: %.1f%%" % accuracy

	# High score display
	if is_new_high_score:
		high_score_label.text = "NOVO RECORDE!"
		high_score_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
		high_score_label.visible = true
		name_edit.visible = true
		save_button.visible = true
	else:
		high_score_label.visible = false
		name_edit.visible = false
		save_button.visible = false

func display_highscores():
	var highscores = Global.highscore_manager.get_top_highscores(3)
	for i in range(highscores.size()):
		var highscore_entry = highscores[i]
		var entry_label = Label.new()
		entry_label.text = str(i+1) + ". " + highscore_entry["name"] + " - " + str(highscore_entry["score"])
		highscore_list.add_child(entry_label)

func play_again() -> void:
	# Restart with same mode and difficulty
	Global.start_game(Global.current_mode, Global.current_difficulty)
	Global.change_scene("res://scenes/Gameplay.tscn")

func go_to_menu() -> void:
	Global.change_scene("res://scenes/MainMenu.tscn")

func _on_SaveButton_pressed():
	if name_edit.text.is_empty():
		return
	Global.highscore_manager.add_highscore(name_edit.text, Global.score)
	name_edit.visible = false
	save_button.visible = false
	# Refresh highscore display
	for child in highscore_list.get_children():
		child.queue_free()
	display_highscores()
