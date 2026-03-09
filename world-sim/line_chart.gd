extends CanvasItem

@export var update_interval : float = 0.2
@export var width = 300
@export var height = 150
@export var data_max = 100.0

var lines : Array[ChartLine] = []

func _ready() -> void:
	for i in range(2):
		var line = ChartLine.new()
		lines.append(line)
		line.length = width
		line.height = height
		line.data_max = data_max
		add_child(line)
		line.default_color = [Color.AQUA, Color.CRIMSON, Color.BLUE, Color.ORANGE, Color.GREEN][i]
		line.is_dotted = i % 2 == 0
	
	var v_border = Line2D.new()
	add_child(v_border)
	v_border.width = 2.0
	v_border.add_point(Vector2(0, height))
	v_border.add_point(Vector2(0, 0))
	
	for i in range(1, 5):
		var v_label = Label.new()
		add_child(v_label)
		v_label.text = str(data_max * i/4.0)
		v_label.size.x = 50
		v_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		v_label.position = Vector2(-v_label.size.x - 15, height * (1.0 - i/4.0) - 12)
		
		var v_tick = Line2D.new()
		add_child(v_tick)
		v_tick.width = 1.0
		v_tick.add_point(Vector2(0, height * (1.0 - i/4.0)))
		v_tick.add_point(Vector2(-10, height * (1.0 - i/4.0)))
	
	var h_border = Line2D.new()
	add_child(h_border)
	h_border.width = 2.0
	h_border.add_point(Vector2(0, height))
	h_border.add_point(Vector2(width, height))
	
	tick()


func tick():
	for line in lines:
		line.push_data(randf() * data_max, 30)
		line.draw()
	
	await get_tree().create_timer(update_interval).timeout
	tick()
