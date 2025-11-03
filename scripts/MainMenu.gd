extends Control

enum MenuCard { TUTORIAL, JOGAR, OPCOES }

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var version_label: Label = $VBoxContainer/VersionLabel
@onready var cards_container: HBoxContainer = $VBoxContainer/CardsContainer
@onready var card_tutorial: Panel = $VBoxContainer/CardsContainer/CardTutorial
@onready var card_jogar: Panel = $VBoxContainer/CardsContainer/CardJogar
@onready var card_opcoes: Panel = $VBoxContainer/CardsContainer/CardOpcoes
@onready var instructions_label: Label = $VBoxContainer/InstructionsLabel
@onready var high_score_label: Label = $HighScoreLabel

var current_card: MenuCard = MenuCard.JOGAR
var cards: Array[Panel] = []

func _ready() -> void:
	# Set up version display
	version_label.text = "ver " + Global.VERSION
	
	# Collect cards
	cards = [card_tutorial, card_jogar, card_opcoes]
	
	# Update card visuals
	update_cards()
	
	# Display high score (show the highest of all)
	update_high_score_display()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left"):
		navigate_card(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_right"):
		navigate_card(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		select_card()
		get_viewport().set_input_as_handled()

func navigate_card(direction: int) -> void:
	current_card = wrapi(current_card + direction, 0, MenuCard.size())
	update_cards()
	# TODO: Play navigation sound

func update_cards() -> void:
	for i in range(cards.size()):
		var card = cards[i]
		if i == current_card:
			# Selected card - larger and centered
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

func select_card() -> void:
	# TODO: Play selection sound
	match current_card:
		MenuCard.TUTORIAL:
			Global.change_scene("res://scenes/Tutorial.tscn")
		MenuCard.JOGAR:
			Global.change_scene("res://scenes/DifficultySelect.tscn")
		MenuCard.OPCOES:
			show_options_menu()

func show_options_menu() -> void:
	# Simple options toggle for now - can be expanded
	Global.sound_enabled = !Global.sound_enabled
	Global.save_game()
	# Show feedback
	var status = "LIGADO" if Global.sound_enabled else "DESLIGADO"
	instructions_label.text = "SOM: " + status + " | SPACE CONFIRMAR"
	
	# Reset after delay
	await get_tree().create_timer(1.0).timeout
	instructions_label.text = "SPACE CONFIRMAR"

func update_high_score_display() -> void:
	var max_score = 0
	for key in Global.high_scores.keys():
		if Global.high_scores[key] > max_score:
			max_score = Global.high_scores[key]
	
	if max_score > 0:
		high_score_label.text = "RECORDE: " + str(max_score)
		high_score_label.visible = true
	else:
		high_score_label.visible = false
