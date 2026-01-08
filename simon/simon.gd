extends Node2D

enum Choice {RED, GREEN, YELLOW, BLUE}

var choice_sequence: Array[Choice] = []

var test_sequence: Array[Choice] = [
	Choice.RED, 
	Choice.YELLOW, 
	Choice.RED, 
	Choice.BLUE,
	Choice.RED, 
	Choice.GREEN, 
	Choice.RED, 
	Choice.GREEN,
	Choice.RED, 
	Choice.BLUE, 
	Choice.RED, 
	Choice.BLUE,
]

@onready var color_rect_red: ColorRect = $ColorRectGrid/Red
@onready var color_rect_green: ColorRect = $ColorRectGrid/Green
@onready var color_rect_yellow: ColorRect = $ColorRectGrid/Yellow
@onready var color_rect_blue: ColorRect = $ColorRectGrid/Blue

func _ready() -> void:
	for c:ColorRect in [
		color_rect_red, 
		color_rect_green, 
		color_rect_yellow,
		color_rect_blue
		]:
		dim(c)
		
	display_sequence(test_sequence)

func light(rect:ColorRect) -> void:
	rect.modulate.v = 1.25
	
func dim(rect:ColorRect) -> void:
	rect.modulate.v = .65

func display_sequence(sequence:Array[Choice]) -> void:
	for index in sequence:
		match index:
			Choice.RED: light(color_rect_red)
			Choice.GREEN: light(color_rect_green)
			Choice.YELLOW: light(color_rect_yellow)
			Choice.BLUE: light(color_rect_blue)
		var timer = get_tree().create_timer(0.5)
		await timer.timeout
		for c:ColorRect in [
			color_rect_red, 
			color_rect_green, 
			color_rect_yellow,
			color_rect_blue
			]:
			dim(c)
