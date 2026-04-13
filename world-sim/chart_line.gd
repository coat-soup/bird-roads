class_name ChartLine
extends Line2D

var data : Array[float]
var is_dotted : bool = false
var length = 300
var height = 50
var data_max = 1.0


func draw():
	width = 3.0 if not is_dotted else 2.0
	if is_dotted:
		texture = preload("res://world-sim/dotted_line.png")
		texture_mode = Line2D.LINE_TEXTURE_TILE
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		texture_repeat = CanvasItem.TEXTURE_REPEAT_MIRROR
	
	clear_points()
	var ld : int = len(data)
	for i in range(ld):
		add_point(Vector2(i * length/float(ld), clamp(height - data[i] / data_max * height, 0, height)))

## max_poins < 0 = infinite
func push_data(value : float, max_points : int = 30):
	data.append(value)
	if max_points > 0 and len(data) > max_points:
		data.remove_at(0)
