extends Control

@onready var content_label: RichTextLabel = $VBoxContainer/ScrollContainer/ContentLabel

func _ready() -> void:
	setup_tutorial_text()

func _input(event: InputEvent) -> void:
	var viewport = get_viewport()
	if not viewport:
		return
	
	if event.is_action_pressed("ui_accept"):
		# Handle input before scene change to avoid null viewport
		viewport.set_input_as_handled()
		go_back()
	elif event.is_action_pressed("Back"):
		# Handle input before scene change to avoid null viewport
		viewport.set_input_as_handled()
		go_back()

func setup_tutorial_text() -> void:
	var tutorial_text = """[center][color=#FFD84D][font_size=42]Como Jogar Pense Rápido![/font_size][/color][/center]

[font_size=24]
[color=#4DFF4D]OBJETIVO:[/color]
Complete 7 fases respondendo perguntas corretamente antes que suas vidas acabem!

[color=#4DFF4D]CONTROLES:[/color]

[color=#FFD84D]Menu Principal:[/color]
• [b]Setas ← →[/b]: Navegar entre opções
• [b]SPACE[/b]: Confirmar seleção

[color=#FFD84D]Seleção de Dificuldade:[/color]
• [b]Setas ← →[/b]: Escolher dificuldade
• [b]Seta ↓[/b]: Alternar entre Matemática e Português
• [b]SPACE[/b]: Começar jogo
• [b]Shift[/b]: Voltar ao menu

[color=#FFD84D]Durante o Jogo:[/color]
• [b]SPACE[/b]: Ativar campo de resposta
• [b]Digite[/b]: Sua resposta
• [b]ENTER[/b]: Confirmar resposta
• [b]Shift[/b]: Desistir (volta ao menu)

[color=#4DFF4D]MECÂNICAS:[/color]

[color=#FFD84D]Perguntas Crescentes:[/color]
As perguntas aparecem pequenas e crescem com o tempo.
Responda antes que fiquem muito grandes!

[color=#FFD84D]Sistema de Vidas:[/color]
Você começa com 3 vidas (×3).
Perde uma vida ao errar ou deixar o tempo acabar.
Jogo termina quando as vidas chegam a zero.

[color=#FFD84D]Fases:[/color]
Complete 7 fases para vencer!
Cada fase tem várias perguntas.

[color=#FFD84D]Dificuldades:[/color]
• [b]FÁCIL[/b]: Perguntas simples, mais tempo (8 segundos)
• [b]MÉDIO[/b]: Perguntas intermediárias (6 segundos)
• [b]DIFÍCIL[/b]: Perguntas avançadas, menos tempo (4 segundos)

[color=#4DFF4D]MODOS DE JOGO:[/color]

[color=#FFD84D]Matemática:[/color]
Resolva contas de adição, subtração, multiplicação e divisão.
Exemplo: "7 × 3" → Digite "21"

[color=#FFD84D]Português:[/color]
Responda perguntas sobre gramática brasileira.
• Classificação de palavras (substantivo, verbo, adjetivo)
• Sílaba tônica
• Ortografia (ç, ss, sc)
• Prosódia (oxítona, paroxítona, proparoxítona)

[color=#4DFF4D]DICAS:[/color]
• Fique atento ao tamanho da pergunta!
• Quanto menor, mais tempo você tem
• Use as explicações quando errar para aprender
• Pratique no modo FÁCIL primeiro!

[/font_size]

[center][color=#4DFF4D][font_size=28]SPACE ou Shift para voltar[/font_size][/color][/center]"""
	
	content_label.text = tutorial_text

func go_back() -> void:
	Global.change_scene("res://scenes/MainMenu.tscn")
