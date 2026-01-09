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
var rows:Array[HBoxContainer] = []
var guess_index: int = 0
#region Rows
@onready var row_0: HBoxContainer = $Rows/Row0
@onready var row_1: HBoxContainer = $Rows/Row1
@onready var row_2: HBoxContainer = $Rows/Row2
@onready var row_3: HBoxContainer = $Rows/Row3
@onready var row_4: HBoxContainer = $Rows/Row4
@onready var row_5: HBoxContainer = $Rows/Row5
@onready var row_6: HBoxContainer = $Rows/Row6
@onready var row_7: HBoxContainer = $Rows/Row7
@onready var row_8: HBoxContainer = $Rows/Row8
@onready var row_9: HBoxContainer = $Rows/Row9
@onready var row_10: HBoxContainer = $Rows/Row10
@onready var row_11: HBoxContainer = $Rows/Row11
#endregion

func _ready() -> void:
	bind_buttons()
	#cpu_color_sequence = pick_color_sequence()
	cpu_color_sequence = [Choice.TURQUOISE, Choice.TURQUOISE, Choice.RED, Choice.RED]
	for row in [row_0, row_1, row_2, row_3, row_4, row_5, row_6, row_7,row_8, row_9, row_10, row_11]:
		rows.append(row)
	print(cpu_color_sequence)

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
	var next_rect = rows[guess_index].guesses[choice_index]
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
	print("clear called")
	for rect in rows[guess_index].guesses:
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
	var guess = evaluate_guess(selected_choice_sequence)
	var results = calculate_results(guess)
	if results.has("red"):
		if results["red"] == 4:
			win()
	display_results(results, rows[guess_index])
	selected_choice_sequence.clear()
	guess_index += 1
	if guess_index > 11:
		lose()
	choice_index = 0
	
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

func win():
	print("winner!")

func lose():
	print("loser!")
