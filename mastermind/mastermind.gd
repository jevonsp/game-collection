extends Node2D

enum Choice {TURQUOISE, CYAN, RED, YELLOW, PURPLE, ORANGE}
var colors:Array[Color] = [
	Color.TURQUOISE, 
	Color.CYAN, 
	Color.RED, 
	Color.YELLOW, 
	Color.REBECCA_PURPLE, 
	Color.ORANGE
	]
var choice_index:int = 0
var selected_choice_sequence:Array = []
var cpu_color_sequence:Array[Choice] = []
var rows:Array[HBoxContainer] = []
var guess_index: int = 0
var wins_in_row: int = 0
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
@onready var cpu_guess: HBoxContainer = $"Cpu Guess"
@onready var play_again: Button = $PlayAgain

func _ready() -> void:
	bind_buttons()
	cpu_color_sequence = pick_color_sequence()
	display_cpu_sequence()
	for row in [row_0, row_1, row_2, row_3, row_4, row_5, row_6, row_7,row_8, row_9, row_10, row_11]:
		rows.append(row)
	for i in range(4):
		selected_choice_sequence.append(null)

func display_cpu_sequence():
	var color_rects = cpu_guess.get_children()
	for i in range(4):
		color_rects[i].color = colors[cpu_color_sequence[i]]

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
	var selected = which.get_meta("choice")
	var slot = choice_index % 4
	
	var next_rect = rows[guess_index].guesses[slot]
	next_rect.color = colors[selected]
	
	selected_choice_sequence[slot] = selected
	
	choice_index = (choice_index + 1) % 4
	
func pick_color_sequence() -> Array[Choice]:
	var res:Array[Choice] = []
	var choices:Array[Choice] = [
		Choice.TURQUOISE, Choice.CYAN, Choice.RED, Choice.YELLOW, Choice.PURPLE, Choice.ORANGE
	]
	for i in range(4):
		res.append(choices.pick_random())
	return res

func _on_clear_pressed() -> void:
	for rect in rows[guess_index].guesses:
		rect.color = Color.WHITE
	selected_choice_sequence = [null, null, null, null]
	choice_index = 0

func _on_accept_pressed() -> void:
	for choice in selected_choice_sequence:
		if choice == null:
			print("enter at least 4 numbers")
			return
	var guess = evaluate_guess(selected_choice_sequence)
	var results = calculate_results(guess)
	if results.has("red"):
		if results["red"] == 4:
			win()
	display_results(results, rows[guess_index])
	selected_choice_sequence  = [null, null, null, null]
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
			
	return [correct_position, correct_color]
	
func calculate_results(guess:Array[int]) -> Dictionary:
	var results = {}
	results["red"] = guess[0]
	results["white"] = guess[1]
	results["none"] = 4 - (guess[0] + guess[1])
	return results

func display_results(results:Dictionary, row:HBoxContainer) -> void:
	for r:ColorRect in row.results:
		if results["red"] > 0:
			r.modulate = Color.WHITE
			r.color = Color.RED
			results["red"] -= 1
		elif results["white"] > 0:
			r.modulate = Color.WHITE
			r.color = Color.WHITE
			results["white"] -= 1
		elif results["none"] > 0:
			r.modulate = Color.TRANSPARENT
			results["none"] -= 1

func win():
	print("winner!")
	clean_up()
	wins_in_row += 1

func lose():
	print("loser!")
	clean_up()
	wins_in_row = 0
	
func clean_up():
	cpu_guess.visible = true
	play_again.visible = true
	guess_index = 0
	choice_index = 0

func clear_rows() -> void:
	for row in rows:
		print("row=%s" % [row])
		for g:ColorRect in row.guesses:
			print("g=%s" % [g])
			g.color = Color.WHITE
		for r:ColorRect in row.results:
			print("r=%s" % [r])
			r.modulate = Color.TRANSPARENT

func _on_play_again_pressed() -> void:
	clear_rows()
	clean_up()
	cpu_guess.visible = false
	play_again.visible = false
	cpu_color_sequence = pick_color_sequence()
	display_cpu_sequence()
