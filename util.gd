class_name Util

static func posheight(pos: Vector2 = Vector2.ZERO, height: float = 0):
	return Vector3(pos.x, height, pos.y)

static func coord(point: Vector3):
	return Vector2(point.x, point.z)

static func randv3(scale: float = 1):
	return Vector3(randf(), randf(), randf()) * scale

static func randv2(scale: float = 1):
	return Vector2(randf(), randf()) * scale

static func randdisp(scale: float = 1):
	return Vector2(randf_range(-1, 1), randf_range(-1, 1)) * scale

static func coinflip():
	return randf() < 0.5

static func antidict(dict: Dictionary):
	var newdict = {}
	for key in dict:
		newdict[dict[key]] = key
	return newdict
