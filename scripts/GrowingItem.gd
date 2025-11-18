extends Control

signal timeout_reached
signal submitted(answer: String)

@onready var question_label: Label = $QuestionLabel
@onready var tween: Tween = null

var growth_time: float = 8.0
var current_scale: float = 0.3
var target_scale: float = 2.0
var is_growing: bool = false
var time_elapsed: float = 0.0

func _ready() -> void:
	scale = Vector2(current_scale, current_scale)
	pivot_offset = size / 2.0  # Center the scaling

func start_growing(question_text: String, grow_time: float) -> void:
	question_label.text = question_text
	growth_time = grow_time
	current_scale = 0.3
	time_elapsed = 0.0
	is_growing = true
	
	# Reset scale
	if tween:
		tween.kill()
	
	scale = Vector2(current_scale, current_scale)
	
	# Create growing animation
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "scale", Vector2(target_scale, target_scale), growth_time)
	tween.finished.connect(_on_growth_finished)

func stop_growing() -> void:
	is_growing = false
	if tween:
		tween.kill()

func reset() -> void:
	stop_growing()
	scale = Vector2(current_scale, current_scale)
	question_label.text = ""
	time_elapsed = 0.0

func get_remaining_time_percent() -> float:
	if growth_time <= 0:
		return 0.0
	return clamp(1.0 - (time_elapsed / growth_time), 0.0, 1.0)

func _process(delta: float) -> void:
	if is_growing:
		time_elapsed += delta

func _on_growth_finished() -> void:
	is_growing = false
	timeout_reached.emit()
