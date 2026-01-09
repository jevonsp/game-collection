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
	var guess = evaluate_guess(selected_choice_sequence)
	var results = calculate_results(guess)
	display_results(results, row)
	_on_clear_pressed()
	
func evaluate_guess(sequence) -> Array[int]:
	var correct_position := 0
	var correct_color := 0
	
	var guess_counts = {}
	var cpu_counts = {}
	
	for i in range(4):
		if sequence[i] == cpu_color_sequence[i]:
			correct_position += 1
		else:
			if sequence[i] in guess_counts:
				guess_counts[sequence[i]] += 1
			else:
				guess_counts[sequence[i]] = 1
			
			if cpu_color_sequence[i] in cpu_counts:
				cpu_counts[cpu_color_sequence[i]] += 1
			else:
				cpu_counts[cpu_color_sequence[i]] = 1
				
	for color in guess_counts:
		if color in cpu_counts:
			correct_color += min(guess_counts[color], cpu_counts[color])
			
	print("Red Pegs: %s" % [correct_position])
	print("White Pegs: %s" % [correct_color])
	return [correct_position, correct_color]
	
func calculate_results(guess:Array[int]) -> Dictionary:
	var results = {}
	results["red"] = guess[0]
	results["white"] = guess[1]
	results["none"] = 4 - (guess[0] + guess[1])
	print(results)
	return results

func display_results(results:Dictionary, row_param:HBoxContainer) -> void:
	for r:ColorRect in row_param.results:
		if results["red"] > 0:
			r.color = Color.RED
			results["red"] -= 1
		elif results["white"] > 0:
			r.color = Color.WHITE
			results["white"] -= 1
		elif results["none"] > 0:
			r.color = Color.TRANSPARENT
			results["none"] -= 1
