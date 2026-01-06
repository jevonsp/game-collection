extends Node2D
@export var cell_size = Vector2(32, 32)
@export var grid_size = Vector2i(20, 20)
var game_cells: Array[Vector2i]
var starting_cells := [Vector2i(9, 9), Vector2i(9, 10), Vector2i(10, 9), Vector2i(10, 10)]
var occupied_cells: Array[Vector2i] = []
var snake_length: int = 0
var start: Vector2i = Vector2i.ZERO  # Changed from Vector2 to Vector2i
var offset: Vector2 = Vector2.ZERO
var snake_direction: Vector2i = Vector2i.RIGHT
var apple_cells: Array[Vector2i] = []
var timer: float = 0.0

func _ready() -> void:
	get_viewport().connect("size_changed", Callable(self, "_on_viewport_size_changed"))
	
	for x in range(20):
		for y in range(20):
			game_cells.append(Vector2i(x, y))
			
	prepare_game()

func prepare_game():
	start = starting_cells.pick_random()
	snake_length = 1
	occupied_cells.append(start)
	
	spawn_apple()

func _process(delta: float) -> void:
	timer += delta
	if timer > (0.2 - (snake_length * 0.001)):
		timer = 0.0
		advance_snake()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("up"):
		turn_snake(Vector2i.UP)
	if event.is_action_pressed("down"):
		turn_snake(Vector2i.DOWN)
	if event.is_action_pressed("left"):
		turn_snake(Vector2i.LEFT)
	if event.is_action_pressed("right"):
		turn_snake(Vector2i.RIGHT)

func _on_viewport_size_changed() -> void:
	queue_redraw()

func _draw() -> void:
	draw_grid()
	draw_snake()
	draw_apples()

func draw_grid():
	var screen_size = get_viewport_rect().size
	
	var grid_width = grid_size.x * cell_size.x
	var grid_height = grid_size.y * cell_size.y
	
	offset = Vector2(
		(screen_size.x - grid_width) / 2.0,
		(screen_size.y - grid_height) / 2.0
	)
	
	for x in grid_size.x + 1:
		var start_x = offset.x + x * cell_size.x
		var start_y = offset.y
		var end_x = offset.x + x * cell_size.x
		var end_y = offset.y + grid_height
		draw_line(
			Vector2(start_x, start_y),
			Vector2(end_x, end_y),
			Color.DARK_GRAY,
			2.0
		)
	
	for y in grid_size.y + 1:
		var start_x = offset.x
		var start_y = offset.y + y * cell_size.y
		var end_x = offset.x + grid_width
		var end_y = offset.y + y * cell_size.y
		draw_line(
			Vector2(start_x, start_y),
			Vector2(end_x, end_y),
			Color.DARK_GRAY,
			2.0
		)

func draw_snake():
	for i in occupied_cells:
		draw_rect(Rect2(offset + (Vector2(i) * cell_size), cell_size), Color.GREEN)
		
func draw_apples():
	for i in apple_cells:
		draw_rect(Rect2(offset + (Vector2(i) * cell_size), cell_size), Color.RED)

func advance_snake():
	var want_to_move = occupied_cells[0] + snake_direction
	
	if want_to_move in occupied_cells:
		print("hit self")
		lose()
		return
	if want_to_move not in game_cells:
		print("hit wall")
		lose()
		return
			
	var ate_apple = false
	for i in apple_cells:
		if want_to_move == i:
			snake_length += 1
			apple_cells.erase(i)
			ate_apple = true
			break

	occupied_cells.push_front(want_to_move)
	
	if not ate_apple:
		occupied_cells.pop_back()
	else:
		spawn_apple()
		
	queue_redraw()
	
func turn_snake(dir: Vector2i):
	if dir == -snake_direction:
		lose()
	snake_direction = dir
	
func spawn_apple():
	var available_cells = game_cells.duplicate()
	for i in available_cells:
		if i in occupied_cells:
			available_cells.erase(i)
		if available_cells.has(i):
			var dist = occupied_cells[0] - i
			if dist.x > 10 or dist.y > 10:
				available_cells.erase(i)
				
	var chosen_cell = available_cells.pick_random()
	apple_cells = [chosen_cell]
	
func lose():
	occupied_cells.clear()
	apple_cells.clear()
	snake_direction = Vector2i.RIGHT
	snake_length = 0
	prepare_game()
