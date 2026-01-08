extends Node2D

enum Choice {TURQUOISE, CYAN, RED, YELLOW, PURPLE, ORANGE}
var colors:Array[Color] = [
	Color.TURQUOISE, 
	Color.CYAN, 
	Color.RED, 
	Color.YELLOW, 
	Color.PURPLE, 
	Color.ORANGE
	]
var choice_index:int = 0
var selected_choice_sequence:Array[Choice] = []
var cpu_color_sequence:Array[Choice] = []
@onready var row: HBoxContainer = $Row

func _ready() -> void:
	bind_buttons()
	#cpu_color_sequence = pick_color_sequence()
	cpu_color_sequence = [Choice.TURQUOISE, Choice.TURQUOISE, Choice.RED, Choice.RED]

func bind_buttons() -> void:
	var buttons := get_tree().get_nodes_in_group("buttons")
	for b:Button in buttons:
		match b.name:
			"Turquoise": b.set_meta("choice", Choice.TURQUOISE)
			"Cyan": b.set_meta("choice", Choice.CYAN)
			"Red": b.set_meta("choice", Choice.RED)
			"Yellow": b.set_meta("choice", Choice.YELLOW)
			"Purple": b.set_meta("choice", Choice.PURPLE)
			"Orange": b.set_meta("choice", Choice.ORANGE)
		var pressed = Callable(self, "_on_pressed").bind(b)
		b.pressed.connect(pressed)
		
func _on_pressed(which: Button) -> void:
	if choice_index >= 4:
		print("Row is full! Press Accept to submit or Clear to reset")
		return
	var selected = which.get_meta("choice")
	var next_rect = row.guesses[choice_index]
	next_rect.color = colors[selected]
	selected_choice_sequence.append(selected)
	choice_index += 1
	
func pick_color_sequence() -> Array[Choice]:
	var res:Array[Choice] = []
	var choices:Array[Choice] = [
		Choice.TURQUOISE, Choice.CYAN, Choice.RED, Choice.YELLOW, Choice.PURPLE, Choice.ORANGE
	]
	for i in range(4):
		res.append(choices.pick_random())
	return res

func _on_clear_pressed() -> void:
	for rect in row.guesses:
		rect.color = Color.WHITE
	selected_choice_sequence.clear()
	choice_index = 0

func _on_accept_pressed() -> void:
	if len(selected_choice_sequence) < 4:
		return
	var choices:Array = [
		"TURQUOISE", "CYAN", "RED", "YELLOW", "PURPLE", "ORANGE"
	]
	for i in range(selected_choice_sequence.size()):
		var index := selected_choice_sequence[i]
		print("i=%s, choice=%s" % [i, choices[index]])
	for rect in row.guesses:
		rect.color = Color.WHITE
	evaluate_guess(selected_choice_sequence)
	_on_clear_pressed()
	
func evaluate_guess(sequence) -> void:
	for i in range(sequence.size()):
		var guess_choice = sequence[i]
		var cpu_choice = cpu_color_sequence[i]
		print("Position %s: guess %s, cpu %s" % [i, guess_choice, cpu_choice])
		print("  Correct color anywhere: %s" % [guess_choice in cpu_color_sequence])
		print("  Correct color and position: %s" % [guess_choice == cpu_choice])
