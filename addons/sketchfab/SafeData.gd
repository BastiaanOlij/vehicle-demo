tool

static func string(data, key):
	return data[key] if _safe_has_key(data, key) && typeof(data[key]) == TYPE_STRING else ""

static func integer(data, key):
	return int(data[key]) if _safe_has_key(data, key) && typeof(data[key]) in [TYPE_INT, TYPE_REAL] else 0

static func array(data, key):
	return data[key] if _safe_has_key(data, key) && typeof(data[key]) == TYPE_ARRAY else []

static func dictionary(data, key):
	return data[key] if _safe_has_key(data, key) && typeof(data[key]) == TYPE_DICTIONARY else {}

static func _safe_has_key(data, key):
	if typeof(data) == TYPE_ARRAY:
		return key < data.size()
	elif typeof(data) == TYPE_DICTIONARY:
		return data.has(key)
	else:
		return false
