extends Control

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var version_label: Label = $VBoxContainer/VersionLabel
@onready var mode_indicator: Label = $VBoxContainer/ModeIndicator
@onready var cards_container: HBoxContainer = $VBoxContainer/CardsContainer
@onready var card_facil: Panel = $VBoxContainer/CardsContainer/CardFacil
@onready var card_medio: Panel = $VBoxContainer/CardsContainer/CardMedio
@onready var card_dificil: Panel = $VBoxContainer/CardsContainer/CardDificil
@onready var instructions_container: HBoxContainer = $VBoxContainer/InstructionsContainer

var current_difficulty: Global.Difficulty = Global.Difficulty.FACIL
var current_mode: Global.GameMode = Global.GameMode.MATH
var cards: Array[Panel] = []

# Sample questions to display on cards
var math_samples = {
	Global.Difficulty.FACIL: ["2+2", "1+4", "Idade: 6-7"],
	Global.Difficulty.MEDIO: ["7×3", "18÷2", "Idade: 7-8"],
	Global.Difficulty.DIFICIL: ["12×8", "144÷12", "Idade: 9"]
}

var language_samples = {
	Global.Difficulty.FACIL: ["casa", "gato", "Idade: 6-7"],
	Global.Difficulty.MEDIO: ["música", "fácil", "Idade: 7-8"],
	Global.Difficulty.DIFICIL: ["Jícara", "Sedex", "Idade: 9"]
}

func _ready() -> void:
	version_label.text = "ver " + Global.VERSION
	cards = [card_facil, card_medio, card_dificil]
	
	update_mode_display()
	update_cards()
	update_card_samples()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left"):
		navigate_difficulty(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_right"):
		navigate_difficulty(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("toggle_mode"):
		toggle_mode()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		start_game()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		go_back()
		get_viewport().set_input_as_handled()

func navigate_difficulty(direction: int) -> void:
	current_difficulty = wrapi(current_difficulty + direction, 0, Global.Difficulty.size())
	update_cards()
	update_card_samples()
	# TODO: Play navigation sound

func toggle_mode() -> void:
	if current_mode == Global.GameMode.MATH:
		current_mode = Global.GameMode.LANGUAGE
	else:
		current_mode = Global.GameMode.MATH
	
	update_mode_display()
	update_card_samples()
	# TODO: Play toggle sound

func update_mode_display() -> void:
	if current_mode == Global.GameMode.MATH:
		mode_indicator.text = "MODO: MATEMÁTICA"
		mode_indicator.add_theme_color_override("font_color", Color(0.3, 0.7, 1.0))
	else:
		mode_indicator.text = "MODO: PORTUGUÊS"
		mode_indicator.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))

func update_cards() -> void:
	for i in range(cards.size()):
		var card = cards[i]
		if i == current_difficulty:
			# Selected card - larger and highlighted
			card.modulate = Color.WHITE
			var tween = create_tween()
			tween.set_ease(Tween.EASE_OUT)
			tween.set_trans(Tween.TRANS_CUBIC)
			tween.tween_property(card, "scale", Vector2(1.1, 1.1), 0.2)
		else:
			# Non-selected cards - smaller and dimmed
			card.modulate = Color(0.6, 0.6, 0.6, 1.0)
			var tween = create_tween()
			tween.set_ease(Tween.EASE_OUT)
			tween.set_trans(Tween.TRANS_CUBIC)
			tween.tween_property(card, "scale", Vector2(0.9, 0.9), 0.2)

func update_card_samples() -> void:
	var samples = math_samples if current_mode == Global.GameMode.MATH else language_samples
	
	# Update FACIL card
	var facil_samples = samples[Global.Difficulty.FACIL]
	card_facil.get_node("VBoxContainer/Sample1").text = facil_samples[0]
	card_facil.get_node("VBoxContainer/Sample2").text = facil_samples[1]
	card_facil.get_node("VBoxContainer/AgeLabel").text = facil_samples[2]
	
	# Update MEDIO card
	var medio_samples = samples[Global.Difficulty.MEDIO]
	card_medio.get_node("VBoxContainer/Sample1").text = medio_samples[0]
	card_medio.get_node("VBoxContainer/Sample2").text = medio_samples[1]
	card_medio.get_node("VBoxContainer/AgeLabel").text = medio_samples[2]
	
	# Update DIFICIL card
	var dificil_samples = samples[Global.Difficulty.DIFICIL]
	card_dificil.get_node("VBoxContainer/Sample1").text = dificil_samples[0]
	card_dificil.get_node("VBoxContainer/Sample2").text = dificil_samples[1]
	card_dificil.get_node("VBoxContainer/AgeLabel").text = dificil_samples[2]

func start_game() -> void:
	# TODO: Play start sound
	Global.start_game(current_mode, current_difficulty)
	Global.change_scene("res://scenes/Gameplay.tscn")

func go_back() -> void:
	# TODO: Play back sound
	Global.change_scene("res://scenes/MainMenu.tscn")

