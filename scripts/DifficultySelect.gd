extends Control

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var version_label: Label = $VBoxContainer/VersionLabel
@onready var mode_indicator: Label = $VBoxContainer/ModeIndicator
@onready var cards_container: HBoxContainer = $VBoxContainer/CardsContainer
@onready var card_facil: Panel = $VBoxContainer/CardsContainer/CardFacil
@onready var card_medio: Panel = $VBoxContainer/CardsContainer/CardMedio
@onready var card_dificil: Panel = $VBoxContainer/CardsContainer/CardDificil
@onready var instructions_container: HBoxContainer = $VBoxContainer/InstructionsContainer
@onready var nav_sound: AudioStreamPlayer = $NavSound
@onready var toggle_sound: AudioStreamPlayer = $ToggleSound
@onready var start_sound: AudioStreamPlayer = $StartSound
@onready var back_sound: AudioStreamPlayer = $BackSound

var current_difficulty: Global.Difficulty = Global.Difficulty.FACIL
var current_mode: Global.GameMode = Global.GameMode.MATH
var cards: Array[Panel] = []
var active_tweens: Array[Tween] = []

# Sample questions to display on cards
var math_samples = {
	Global.Difficulty.FACIL: ["2+2", "1+4", "Idade: 6-7"],
	Global.Difficulty.MEDIO: ["7×3", "18÷2", "Idade: 7-8"],
	Global.Difficulty.DIFICIL: ["12×8", "144÷12", "Idade: 9"]
}

var language_samples = {
	Global.Difficulty.FACIL: ["Casa", "Gato", "Idade: 6-7"],
	Global.Difficulty.MEDIO: ["Música", "Cabeça", "Idade: 7-8"],
	Global.Difficulty.DIFICIL: ["Xícara", "Sedex", "Idade: 9"]
}

func _ready() -> void:
	version_label.text = "ver " + Global.VERSION
	cards = [card_facil, card_medio, card_dificil]
	
	update_mode_display()
	update_cards()
	update_card_samples()

func _input(event: InputEvent) -> void:
	var viewport = get_viewport()
	if not viewport:
		return
	
	if event.is_action_pressed("ui_left"):
		navigate_difficulty(-1)
		viewport.set_input_as_handled()
	elif event.is_action_pressed("ui_right"):
		navigate_difficulty(1)
		viewport.set_input_as_handled()
	elif event.is_action_pressed("toggle_mode"):
		toggle_mode()
		viewport.set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		# Handle input before scene change to avoid null viewport
		viewport.set_input_as_handled()
		start_game()
	elif event.is_action_pressed("Back"):
		# Handle input before scene change to avoid null viewport
		viewport.set_input_as_handled()
		go_back()

func navigate_difficulty(direction: int) -> void:
	current_difficulty = wrapi(current_difficulty + direction, 0, Global.Difficulty.size())
	update_cards()
	update_card_samples()
	if Global.sound_enabled:
		nav_sound.play()

func toggle_mode() -> void:
	if current_mode == Global.GameMode.MATH:
		current_mode = Global.GameMode.LANGUAGE
	else:
		current_mode = Global.GameMode.MATH
	
	update_mode_display()
	update_card_samples()
	if Global.sound_enabled:
		toggle_sound.play()

func update_mode_display() -> void:
	if current_mode == Global.GameMode.MATH:
		mode_indicator.text = "MODO: MATEMÁTICA"
		mode_indicator.add_theme_color_override("font_color", Color(0.3, 0.7, 1.0))
	else:
		mode_indicator.text = "MODO: PORTUGUÊS"
		mode_indicator.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))

func update_cards() -> void:
	# Kill all existing tweens first
	kill_all_tweens()
	
	for i in range(cards.size()):
		var card = cards[i]
		if i == current_difficulty:
			# Selected card - larger and highlighted
			card.modulate = Color.WHITE
			var tween = create_tween()
			tween.set_ease(Tween.EASE_OUT)
			tween.set_trans(Tween.TRANS_CUBIC)
			tween.tween_property(card, "scale", Vector2(1.1, 1.1), 0.2)
			active_tweens.append(tween)
		else:
			# Non-selected cards - smaller and dimmed
			card.modulate = Color(0.6, 0.6, 0.6, 1.0)
			var tween = create_tween()
			tween.set_ease(Tween.EASE_OUT)
			tween.set_trans(Tween.TRANS_CUBIC)
			tween.tween_property(card, "scale", Vector2(0.9, 0.9), 0.2)
			active_tweens.append(tween)

func kill_all_tweens() -> void:
	for tween in active_tweens:
		if is_instance_valid(tween):
			tween.kill()
	active_tweens.clear()

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
	# Kill all active tweens before changing scene to prevent crashes
	kill_all_tweens()
	if Global.sound_enabled:
		start_sound.play()
	Global.start_game(current_mode, current_difficulty)
	Global.change_scene("res://scenes/Gameplay.tscn")

func go_back() -> void:
	# Kill all active tweens before changing scene to prevent crashes
	kill_all_tweens()
	if Global.sound_enabled:
		back_sound.play()
	Global.change_scene("res://scenes/MainMenu.tscn")
