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
var is_playing: bool = false
var timer: float = 0.0
var time_allowed: float = 2.0
@onready var color_rect_red: ColorRect = $ColorRectGrid/Red
@onready var color_rect_green: ColorRect = $ColorRectGrid/Green
@onready var color_rect_yellow: ColorRect = $ColorRectGrid/Yellow
@onready var color_rect_blue: ColorRect = $ColorRectGrid/Blue
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var time_label: Label = $TimeLabel
@onready var score_label: Label = $VBoxContainer/ScoreLabel
@onready var hi_score_label: Label = $VBoxContainer/HiScoreLabel

# Timing constants
const LIGHT_DURATION: float = 0.4		# How long each color lights up
const BETWEEN_LIGHTS: float = 0.15		# Pause between colors
const ROUND_START_DELAY: float = 0.8	# Delay before showing sequence
const PLAYER_TURN_DELAY: float = 0.1	# Delay before player can click

func _ready() -> void:
	prepare_game()

func prepare_game():
	var buttons = get_tree().get_nodes_in_group("buttons")
	for b:Button in buttons:
		match b.name:
			"Red": b.set_meta("choice", Choice.RED)
			"Green": b.set_meta("choice", Choice.GREEN)
			"Yellow": b.set_meta("choice", Choice.YELLOW)
			"Blue": b.set_meta("choice", Choice.BLUE)
		var pressed = Callable(self, "_on_pressed").bind(b)
		b.pressed.connect(pressed)
	dim_all()
	update_labels()
	
func _process(delta: float) -> void:
	time_label.text = "Time Left: %2.2f" % [time_allowed - timer]
	if is_player_turn:
		timer += delta
	if timer >= time_allowed:
		lose()

func _input(event: InputEvent) -> void:
		if event.is_action_pressed("ui_cancel"):
			quit()

func set_vars(gd: GameData) -> void:
	hi_score = int(gd.hi_score)

func _on_pressed(which: Button) -> void:
	if not is_player_turn:
		return
		
	var choice: Choice = which.get_meta("choice")
	var expected = game_sequence[choice_index]
	
	# Visual/audio feedback
	match choice:
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

	await get_tree().create_timer(0.2).timeout
	dim_all()
	
	if choice != expected:
		await get_tree().create_timer(0.5).timeout
		lose()
		return
	
	choice_index += 1
	score += 1
	update_labels()
	timer = 0.0
	
	if choice_index >= len(game_sequence):
		await get_tree().create_timer(0.6).timeout
		next_loop()

func light(rect: ColorRect) -> void:
	rect.modulate.v = 1.25
	
func dim(rect: ColorRect) -> void:
	rect.modulate.v = .65

func dim_all() -> void:
	for c:ColorRect in [color_rect_red, color_rect_green, color_rect_yellow, color_rect_blue]:
		dim(c)

func display_sequence(sequence: Array[Choice]) -> void:
	dim_all()
	audio_stream_player.stop()
	
	var buttons = get_tree().get_nodes_in_group("buttons")
	for b:Button in buttons:
		b.disabled = true
	
	await get_tree().create_timer(ROUND_START_DELAY).timeout
	
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
		
		await get_tree().create_timer(LIGHT_DURATION).timeout
		
		dim_all()
		
		await get_tree().create_timer(BETWEEN_LIGHTS).timeout
	
	await get_tree().create_timer(PLAYER_TURN_DELAY).timeout
	
	for b:Button in buttons:
		b.disabled = false

func increment_sequence() -> void:
	var next:Choice = [Choice.RED, Choice.GREEN, Choice.YELLOW, Choice.BLUE].pick_random()
	game_sequence.append(next)

func start_game():
	next_loop()

func next_loop():
	increment_sequence()
	choice_index = 0
	timer = 0.0
	is_player_turn = false
	
	await display_sequence(game_sequence)
	choice_expecting = game_sequence[0]
	is_player_turn = true

func lose():
	is_playing = false
	is_player_turn = false
	
	audio_stream_player.pitch_scale = 0.4
	audio_stream_player.play()
	timer = 0.0
	
	if score > hi_score:
		hi_score = score
	score = 0
	
	update_labels()
	game_sequence.clear()
	
	await get_tree().create_timer(1.0).timeout

func _on_play_button_pressed() -> void:
	if is_playing:
		return
	start_game()
	is_playing = true

func update_labels():
	score_label.text = "%s" % [score]
	hi_score_label.text = "%s" % [hi_score]

func quit():
	if score > hi_score:
		hi_score = score
	var gd = GameData.new()
	gd.name = "simon"
	gd.hi_score = hi_score
	game_data_sent.emit(gd)
	game_quit.emit()
	queue_free()
