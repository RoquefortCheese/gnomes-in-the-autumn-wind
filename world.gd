extends Node
class_name World

enum Vox {AIR, BOARD}
const chunksize = 8
const maxradius = 8

@export var noise: FastNoiseLite
var voxels: Dictionary[Vector3, Vox]
var chunks: Dictionary[Vector3, Chunk]

func voxat(point: Vector3):
	if point in voxels:
		return voxels[point]
	var voxel = genvox(point)
	voxels[point] = voxel
	return voxel

func genvox(point: Vector3):
	if max(abs(point.x), abs(point.y), abs(point.z)) <= 16:
		return Vox.AIR
	var sample = (noise.get_noise_3dv(point) + 1) / 2
	var threshold = 0.25
	var strata = point.y / 12 + 2
	threshold += 0.5 / (strata ** 4 + 1)
	threshold += 0.25 / (exp(strata) + 1)
	if sample < threshold:
		return Vox.BOARD
	return Vox.AIR

func loadchunk(point: Vector3):
	var chunk = load("res://chunk.tscn").instantiate()
	$Chunks.add_child(chunk)
	chunks[point] = chunk
	chunk.create(self, point)

func _ready():
	noise.seed = randi()

func _process(delta: float):
	genstuff()

func genstuff():
	var start = Time.get_ticks_msec()
	var iters = 0
	while true:
		var options = []
		var playerchunk = floor($Player.position / chunksize) * chunksize
		for radius in maxradius:
			for x in range(-radius, radius + 1):
				for y in range(-radius, radius + 1):
					for z in range(-radius, radius + 1):
						var point = Vector3(x, y, z) * chunksize + playerchunk
						if point not in chunks:
							options.append(point)
			if options:
				break
		if not options:
			break
		loadchunk(options.pick_random())
		iters += 1
		var timepassed = Time.get_ticks_msec() - start
		if timepassed + float(timepassed) / iters > 12:
			break
