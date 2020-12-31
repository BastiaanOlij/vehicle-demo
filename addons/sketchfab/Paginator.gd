tool
extends ScrollContainer

const SafeData = preload("res://addons/sketchfab/SafeData.gd")
var ResultItem = load("res://addons/sketchfab/ResultItem.tscn")

var api = preload("res://addons/sketchfab/Api.gd").new()

onready var grid = find_node("ResultsGrid")
onready var trailer = find_node("Trailer")
onready var label = find_node("Label")
onready var cta_button = find_node("CTA")
onready var search_domain = find_node("SearchDomain")

var next_page_url

func _ready():
	trailer.modulate.a = 0.0

func _exit_tree():
	api.term()

func search(query, categories, animated, staff_picked, min_face_count, max_face_count, sort_by, domain_suffix):
	for item in grid.get_children():
		grid.remove_child(item)
	queue_sort()

	trailer.modulate.a = 1.0
	label.text = "Fetching..."
	cta_button.hide()
	yield(api.cancel(), "completed")
	var result = yield(api.search_models(
		query,
		categories,
		animated,
		staff_picked,
		min_face_count,
		max_face_count,
		sort_by,
		domain_suffix
	), "completed")
	trailer.modulate.a = 0.0

	var n_results = _process_page(result)

	# Upgrade to pro and empty results
	if domain_suffix == "/me":
		var user = yield(api.get_my_info(), "completed")
		if user["account"] == "plus" || user["account"] == "basic":
			trailer.modulate.a = 1.0
			label.text = "Access your personal library of 3D models"
			cta_button.show()
			cta_button.text = "Upgrade to PRO"
		elif n_results == 0:
			trailer.modulate.a = 1.0
			label.text = "No results found"
	elif n_results == 0:
		trailer.modulate.a = 1.0
		label.text = "No results found"
		if domain_suffix == "/me/models/purchases":
			cta_button.show()
			cta_button.text = "Visit the Store"
	else:
		trailer.modulate.a = 0.0
		cta_button.hide()

func _process(delta):
	if !api.busy && next_page_url && trailer.get_global_rect().intersects(get_viewport_rect()):
		# Fetch next page
		trailer.modulate.a = 1.0
		label.text = "Fetching..."
		cta_button.hide()
		var result = yield(api.fetch_next_page(next_page_url), "completed")
		trailer.modulate.a = 0.0

		_process_page(result)

func _process_page(result):
	next_page_url = null

	# Canceled?
	if !result:
		return

	# Collect and check
	if typeof(result) != TYPE_DICTIONARY:
		return

	# Process
	var results = SafeData.array(result, "results")
	for result in results:
		var item = ResultItem.instance()
		item.set_data(result)
		grid.add_child(item)

	# Set next page now we know the current one succeeded
	next_page_url = SafeData.string(result, "next")

	return results.size()
