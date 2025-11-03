extends Control

@onready var phase_container: HBoxContainer = $TopBar/PhaseContainer
@onready var info_panel: VBoxContainer = $TopBar/InfoPanel
@onready var mode_label: Label = $TopBar/InfoPanel/ModeLabel
@onready var lives_label: Label = $TopBar/InfoPanel/LivesLabel
@onready var difficulty_label: Label = $TopBar/InfoPanel/DifficultyLabel

@onready var growing_item_container: CenterContainer = $GrowingItemContainer
@onready var question_label: Label = $GrowingItemContainer/QuestionLabel

@onready var input_container: VBoxContainer = $BottomBar/InputContainer
@onready var input_prompt: Label = $BottomBar/InputContainer/InputPrompt
@onready var answer_input: LineEdit = $BottomBar/InputContainer/AnswerInput
@onready var option_buttons_container: VBoxContainer = $BottomBar/InputContainer/OptionButtonsContainer

@onready var explanation_popup: Panel = $ExplanationPopup

var phase_boxes: Array[Panel] = []
var current_question: Dictionary = {}
var all_questions: Array = []
var used_questions: Array = []
var questions_in_phase: int = 0
var questions_answered_in_phase: int = 0
var is_input_active: bool = false
var growth_tween: Tween = null
var question_start_time: float = 0.0
var growth_time: float = 8.0

func _ready() -> void:
	setup_phase_indicators()
	setup_ui()
	load_questions()
	start_phase()

func setup_phase_indicators() -> void:
	var settings = Global.get_difficulty_settings()
	var total_phases = settings["phases"]
	
	for i in range(total_phases):
		var phase_box = Panel.new()
		phase_box.custom_minimum_size = Vector2(50, 50)
		
		# Create style
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.3, 0.3, 0.3, 1.0)
		style.corner_radius_top_left = 5
		style.corner_radius_top_right = 5
		style.corner_radius_bottom_left = 5
		style.corner_radius_bottom_right = 5
		phase_box.add_theme_stylebox_override("panel", style)
		
		# Add number label
		var label = Label.new()
		label.text = str(i + 1)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 24)
		label.anchor_right = 1.0
		label.anchor_bottom = 1.0
		phase_box.add_child(label)
		
		phase_container.add_child(phase_box)
		phase_boxes.append(phase_box)
	
	update_phase_indicators()

func setup_ui() -> void:
	mode_label.text = "Modo " + Global.get_difficulty_name()
	difficulty_label.text = "Dificuldade"
	update_lives_display()
	
	# Hide input initially
	answer_input.visible = false
	answer_input.editable = false
	option_buttons_container.visible = false
	
	# Connect input signal
	answer_input.text_submitted.connect(_on_answer_submitted)

func load_questions() -> void:
	var file_path = ""
	var difficulty_key = ""
	
	match Global.current_difficulty:
		Global.Difficulty.FACIL:
			difficulty_key = "facil"
		Global.Difficulty.MEDIO:
			difficulty_key = "medio"
		Global.Difficulty.DIFICIL:
			difficulty_key = "dificil"
	
	if Global.current_mode == Global.GameMode.MATH:
		file_path = "res://data/math_questions.json"
	else:
		file_path = "res://data/language_questions.json"
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var error = json.parse(json_text)
		if error == OK:
			var data = json.data
			if data.has(difficulty_key):
				all_questions = data[difficulty_key]["questions"].duplicate()
				all_questions.shuffle()
		else:
			push_error("Failed to parse questions JSON: " + json.get_error_message())
	else:
		push_error("Failed to open questions file: " + file_path)

func start_phase() -> void:
	if Global.check_victory():
		game_over(true)
		return
	
	var settings = Global.get_difficulty_settings()
	questions_in_phase = settings["questions_per_phase"]
	questions_answered_in_phase = 0
	growth_time = settings["growth_time"]
	
	update_phase_indicators()
	next_question()

func next_question() -> void:
	if questions_answered_in_phase >= questions_in_phase:
		# Phase complete
		Global.advance_phase()
		start_phase()
		return
	
	if Global.check_defeat():
		game_over(false)
		return
	
	# Get a random unused question
	if all_questions.is_empty():
		# Reload questions if we ran out
		load_questions()
	
	if all_questions.is_empty():
		push_error("No questions available!")
		return
	
	current_question = all_questions.pop_front()
	used_questions.append(current_question)
	
	# Display question
	display_question()
	start_growing_animation()

func display_question() -> void:
	# Reset question display
	question_label.scale = Vector2(0.3, 0.3)
	question_label.pivot_offset = question_label.size / 2.0
	
	# Clear previous options
	for child in option_buttons_container.get_children():
		child.queue_free()
	
	if Global.current_mode == Global.GameMode.MATH:
		question_label.text = current_question.get("text", "")
		answer_input.visible = false
		answer_input.editable = false
		option_buttons_container.visible = false
		input_prompt.text = "ESPAÇO PARA DIGITAR"
	else:
		# Language mode
		question_label.text = current_question.get("text", "")
		
		if current_question.get("type") == "classification" or current_question.get("type") == "syllable" or current_question.get("type") == "spelling":
			# Show options as buttons
			var options = current_question.get("options", [])
			if not options.is_empty():
				option_buttons_container.visible = true
				answer_input.visible = false
				input_prompt.text = current_question.get("question", "")
				
				for i in range(options.size()):
					var btn = Button.new()
					btn.text = options[i]
					btn.custom_minimum_size = Vector2(200, 50)
					btn.add_theme_font_size_override("font_size", 20)
					btn.pressed.connect(_on_option_selected.bind(options[i]))
					option_buttons_container.add_child(btn)
			else:
				answer_input.visible = false
				answer_input.editable = false
				option_buttons_container.visible = false
				input_prompt.text = "ESPAÇO PARA DIGITAR"
		else:
			answer_input.visible = false
			answer_input.editable = false
			option_buttons_container.visible = false
			input_prompt.text = "ESPAÇO PARA DIGITAR"
	
	is_input_active = false
	answer_input.text = ""
	question_start_time = Time.get_ticks_msec() / 1000.0

func start_growing_animation() -> void:
	if growth_tween:
		growth_tween.kill()
	
	question_label.scale = Vector2(0.3, 0.3)
	
	growth_tween = create_tween()
	growth_tween.set_ease(Tween.EASE_IN)
	growth_tween.set_trans(Tween.TRANS_QUAD)
	growth_tween.tween_property(question_label, "scale", Vector2(2.0, 2.0), growth_time)
	growth_tween.finished.connect(_on_timeout)

func _input(event: InputEvent) -> void:
	if explanation_popup.visible:
		if event.is_action_pressed("ui_accept"):
			hide_explanation()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_cancel"):
			give_up()
			get_viewport().set_input_as_handled()
		return
	
	if event.is_action_pressed("ui_accept") and not is_input_active:
		if not option_buttons_container.visible:
			activate_input()
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		give_up()
		get_viewport().set_input_as_handled()

func activate_input() -> void:
	is_input_active = true
	answer_input.visible = true
	answer_input.editable = true
	answer_input.grab_focus()
	input_prompt.text = "Digite e pressione ENTER"

func _on_answer_submitted(answer_text: String) -> void:
	check_answer(answer_text)

func _on_option_selected(option: String) -> void:
	check_answer(option)

func check_answer(answer: String) -> void:
	if current_question.is_empty():
		return
	
	var correct_answer = str(current_question.get("answer", ""))
	var is_correct = false
	
	# For math, convert to int/float for comparison
	if Global.current_mode == Global.GameMode.MATH:
		is_correct = answer.strip_edges() == correct_answer
	else:
		# For language, case-insensitive comparison
		is_correct = answer.strip_edges().to_lower() == correct_answer.to_lower()
	
	if is_correct:
		on_correct_answer()
	else:
		on_wrong_answer()

func on_correct_answer() -> void:
	# TODO: Play correct sound
	
	# Calculate score based on time remaining
	var time_elapsed = (Time.get_ticks_msec() / 1000.0) - question_start_time
	var time_remaining_percent = clamp(1.0 - (time_elapsed / growth_time), 0.0, 1.0)
	var points = int(time_remaining_percent * 100)
	
	Global.add_score(points)
	questions_answered_in_phase += 1
	
	# Stop animation
	if growth_tween:
		growth_tween.kill()
	
	# Next question
	next_question()

func on_wrong_answer() -> void:
	# TODO: Play wrong sound
	Global.lose_life()
	update_lives_display()
	
	# Stop animation
	if growth_tween:
		growth_tween.kill()
	
	# Show explanation
	show_explanation()

func _on_timeout() -> void:
	# Time ran out
	on_wrong_answer()

func show_explanation() -> void:
	explanation_popup.visible = true
	
	var question_text = current_question.get("text", "")
	var correct_answer = str(current_question.get("answer", ""))
	var explanation = current_question.get("explanation", "Resposta correta: " + correct_answer)
	
	var question_label_popup = explanation_popup.get_node("VBoxContainer/QuestionLabel")
	var answer_label = explanation_popup.get_node("VBoxContainer/AnswerLabel")
	var explanation_label = explanation_popup.get_node("VBoxContainer/ExplanationLabel")
	
	question_label_popup.text = "Pergunta: " + question_text
	answer_label.text = "Resposta: " + correct_answer
	explanation_label.text = explanation

func hide_explanation() -> void:
	explanation_popup.visible = false
	
	if Global.check_defeat():
		game_over(false)
	else:
		next_question()

func update_lives_display() -> void:
	lives_label.text = "×" + str(Global.lives)
	
	# Change color based on lives
	if Global.lives <= 1:
		lives_label.add_theme_color_override("font_color", Color.RED)
	elif Global.lives <= 2:
		lives_label.add_theme_color_override("font_color", Color.YELLOW)
	else:
		lives_label.add_theme_color_override("font_color", Color.GREEN)

func update_phase_indicators() -> void:
	for i in range(phase_boxes.size()):
		var style = StyleBoxFlat.new()
		style.corner_radius_top_left = 5
		style.corner_radius_top_right = 5
		style.corner_radius_bottom_left = 5
		style.corner_radius_bottom_right = 5
		
		if i < Global.current_phase:
			# Completed phase - green
			style.bg_color = Color(0.3, 1.0, 0.3, 1.0)
		elif i == Global.current_phase:
			# Current phase - yellow
			style.bg_color = Color(1.0, 0.85, 0.3, 1.0)
		else:
			# Future phase - gray
			style.bg_color = Color(0.3, 0.3, 0.3, 1.0)
		
		phase_boxes[i].add_theme_stylebox_override("panel", style)

func give_up() -> void:
	# TODO: Show confirmation dialog
	Global.change_scene("res://scenes/MainMenu.tscn")

func game_over(victory: bool) -> void:
	# Save high score if applicable
	var is_new_high_score = Global.update_high_score()
	
	# Go to game over scene (will create next)
	Global.change_scene("res://scenes/GameOver.tscn")

func _on_explanation_continue_pressed() -> void:
	hide_explanation()

func _on_explanation_give_up_pressed() -> void:
	give_up()

