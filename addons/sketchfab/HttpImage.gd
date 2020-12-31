tool
extends Control

const MAX_COUNT = 4

export var max_size = 256
export var background = Color(0, 0, 0, 0)
export var immediate = false

var url setget _set_url
var url_to_load

var http = HTTPRequest.new()
var busy

var texture

func _enter_tree():
	if !get_tree().has_meta("__http_image_count"):
		get_tree().set_meta("__http_image_count", 0)

	if !http.get_parent():
		add_child(http)

	busy = false
	if url_to_load:
		_start_load()

func _exit_tree():
	if busy:
		http.cancel_request()
		get_tree().set_meta("__http_image_count", get_tree().get_meta("__http_image_count") - 1)
		busy = false

func _draw():
	var rect = Rect2(0, 0, get_rect().size.x, get_rect().size.y)
	draw_rect(rect, background)

	if !texture:
		return

	var tw = texture.get_width()
	var th = texture.get_height()

	if float(tw) / th > rect.size.x / rect.size.y:
		var old = rect.size.y
		rect.size.y = rect.size.x * float(th) / tw
		rect.position.y += 0.5 * (old - rect.size.y)
	else:
		var old = rect.size.x
		rect.size.x = rect.size.y * float(tw) / th
		rect.position.x += 0.5 * (old - rect.size.x)

	draw_texture_rect(texture, rect, false)

func _set_url(url):
	url_to_load = url
	if !is_inside_tree():
		return

	_start_load()

func _start_load():
	http.cancel_request()
	texture = null
	update()

	if !url_to_load:
		return

	while true:
		if !is_inside_tree():
			return
		var count = get_tree().get_meta("__http_image_count")
		if immediate || count < MAX_COUNT:
			get_tree().set_meta("__http_image_count", count + 1)
			break
		else:
			yield(get_tree(), "idle_frame")

	_load(url_to_load)
	url_to_load = null

func _load(url_to_load):
	http.request(url_to_load, [], false)

	busy = true
	var data = yield(http, "request_completed")

	busy = false
	get_tree().set_meta("__http_image_count", get_tree().get_meta("__http_image_count") - 1)

	var result = data[0]
	var code = data[1]
	var headers = data[2]
	var body = data[3]

	if result != HTTPRequest.RESULT_SUCCESS:
		return

	var img = Image.new()
	if img.load_jpg_from_buffer(body) == OK || img.load_png_from_buffer(body) == OK:
		var w = img.get_width()
		var h = img.get_height()
		if w > h:
			var new_w = min(w, max_size)
			img.resize(new_w, (float(h) / w) * new_w)
		else:
			var new_h = min(h, max_size)
			img.resize((float(w) / h) * new_h, new_h)

		texture = ImageTexture.new()
		texture.create_from_image(img)
		update()
