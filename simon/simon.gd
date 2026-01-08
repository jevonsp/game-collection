extends Node2D
signal game_data_sent(gd: GameData)
signal game_quit
enum Choice {RED, GREEN, YELLOW, BLUE}
var game_sequence: Array[Choice] = []
var choice_expecting: Choice
var choice_index: int = 0
var score: int = 0
var hi_score: int = 0
var is_player_turn: bool = false
var timer: float = 0.0
var time_allowed: float = 2.0

@onready var color_rect_red: ColorRect = $ColorRectGrid/Red
@onready var color_rect_green: ColorRect = $ColorRectGrid/Green
@onready var color_rect_yellow: ColorRect = $ColorRectGrid/Yellow
@onready var color_rect_blue: ColorRect = $ColorRectGrid/Blue
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	var buttons = get_tree().get_nodes_in_group("buttons")
	for b:Button in buttons:
		match b.name:
			"Red": b.set_meta("choice", Choice.RED)
			"Green": b.set_meta("choice", Choice.GREEN)
			"Yellow": b.set_meta("choice", Choice.YELLOW)
			"Blue": b.set_meta("choice", Choice.BLUE)
		var pressed = Callable(self, "_on_pressed").bind(b)
		b.pressed.connect(pressed)
		
	start_game()

func _process(delta: float) -> void:
	if is_player_turn:
		timer += delta
	if timer >= time_allowed:
		lose()

func set_vars(gd: GameData) -> void:
	hi_score = int(gd.hi_score)

func _on_pressed(which: Button) -> void:
	var choice: Choice = which.get_meta("choice")
	if choice != game_sequence[choice_index]:
		lose()
		return
	print("clicked right")
	choice_index += 1
	score += 1
	timer = 0.0
	if choice_index >= len(game_sequence):
		next_loop()

func light(rect:ColorRect) -> void:
	rect.modulate.v = 1.25
	
func dim(rect:ColorRect) -> void:
	rect.modulate.v = .65

func display_sequence(sequence:Array[Choice]) -> void:
	var buttons = get_tree().get_nodes_in_group("buttons")
	for b:Button in buttons:
		b.disabled = true
	
	for index in sequence:
		match index:
			Choice.RED: 
				light(color_rect_red)
				audio_stream_player.pitch_scale = 1.0
				audio_stream_player.play()
			Choice.GREEN: 
				light(color_rect_green)
				audio_stream_player.pitch_scale = 1.1
				audio_stream_player.play()
			Choice.YELLOW: 
				light(color_rect_yellow)
				audio_stream_player.pitch_scale = 1.2
				audio_stream_player.play()
			Choice.BLUE: 
				light(color_rect_blue)
				audio_stream_player.pitch_scale = .9
				audio_stream_player.play()
		var button_timer = get_tree().create_timer(0.5)
		await button_timer.timeout
		for c:ColorRect in [
			color_rect_red, 
			color_rect_green, 
			color_rect_yellow,
			color_rect_blue
			]:
			dim(c)
			
	for b:Button in buttons:
		b.disabled = false

func increment_sequence() -> void:
	var next:Choice = [Choice.RED, Choice.GREEN, Choice.YELLOW, Choice.BLUE].pick_random()
	game_sequence.append(next)

func start_game():
	for c:ColorRect in [
		color_rect_red, 
		color_rect_green, 
		color_rect_yellow,
		color_rect_blue
		]:
		dim(c)
		
	next_loop()

func next_loop():
	increment_sequence()
	await display_sequence(game_sequence)
	choice_expecting = game_sequence[0]
	is_player_turn = true

func lose():
	score = 0
	game_sequence.clear()
	
	next_loop()
