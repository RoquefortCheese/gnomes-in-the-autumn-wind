extends Node
class_name World

enum Vox {AIR, BOARD}
const chunksize = 8
const maxradius = 5

@export var noise: FastNoiseLite
var voxels: Dictionary[Vector3, Vox]
var chunks: Dictionary[Vector3, Chunk]
var gnomes: Array[Gnome]

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
	#var threshold = 0.25
	#var strata = point.y / 12 + 2
	#threshold += 0.5 / (strata ** 4 + 1)
	#threshold += 0.25 / (exp(strata) + 1)
	if sample < 0.5:
		return Vox.BOARD
	return Vox.AIR

func loadchunk(point: Vector3):
	var chunk = load("res://chunk.tscn").instantiate()
	$Chunks.add_child(chunk)
	chunks[point] = chunk
	chunk.create(self, point)

func _ready():
	Global.world = self
	noise.seed = randi()

func _process(delta: float):
	genstuff()
	ungenstuff()

func playerchunk():
	return floor($Player.position / chunksize) * chunksize

func chunksortmetric(one: Vector3, two: Vector3):
	var onedist = (one + Vector3.ONE * chunksize / 2 - $Player.position).length()
	var twodist = (two + Vector3.ONE * chunksize / 2 - $Player.position).length()
	return onedist < twodist

func genstuff():
	var start = Time.get_ticks_msec()
	var iters = 0
	while true:
		var centerchunk = playerchunk()
		var options = []
		var donepoints = {}
		for radius in maxradius:
			for theta in range(0, TAU, PI / 16):
				for phi in range(-PI / 2, PI / 2, PI / 16):
					var point = floor(Vector3(cos(theta) * cos(phi), sin(phi), sin(theta) * cos(phi)))
					print(point)
					if point in donepoints:
						continue
					donepoints[point] = true
					var vox = point * chunksize
					print(vox)
					if vox not in chunks:
						options.append(vox)
			if options:
				break
		if not options:
			break
		loadchunk(options.pick_random())
		var timepassed = Time.get_ticks_msec() - start
		if timepassed + float(timepassed) / iters > 12:
			print("iters: " + str(iters))
			#print("voxels per ms: " + str(float(chunksize) ** 3 * iters / timepassed))
			break

func ungenstuff():
	var centerchunk = playerchunk()
	for chunk in chunks.keys():
		var disp = (chunk - centerchunk) / chunksize
		if max(abs(disp.x), abs(disp.y), abs(disp.z)) > maxradius:
			$Chunks.remove_child(chunks[chunk])
			chunks.erase(chunk)
