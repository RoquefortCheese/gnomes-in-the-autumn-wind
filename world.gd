extends Node
class_name World

enum Vox {AIR, BOARD}
const chunksize = 12
const maxradius = 8

@export var noise: FastNoiseLite
var voxels: Dictionary[Vector3, Vox]
var chunks: Dictionary[Vector3, Chunk]
var gnomes: Array[Gnome]

func voxat(point: Vector3) -> Vox:
	if point in voxels:
		return voxels[point]
	var voxel := genvox(point)
	voxels[point] = voxel
	return voxel

func genvox(point: Vector3) -> Vox:
	if max(abs(point.x), abs(point.y), abs(point.z)) <= 16:
		return Vox.AIR
	var sample := (noise.get_noise_3dv(point) + 1) / 2
	#var threshold = 0.25
	#var strata = point.y / 12 + 2
	#threshold += 0.5 / (strata ** 4 + 1)
	#threshold += 0.25 / (exp(strata) + 1)
	if sample < 0.6:
		return Vox.BOARD
	return Vox.AIR

func loadchunk(point: Vector3) -> void:
	var chunk: Chunk = load("res://chunk.tscn").instantiate()
	$Chunks.add_child(chunk)
	chunks[point] = chunk
	chunk.create(self, point)

func _ready() -> void:
	Global.world = self
	noise.seed = randi()

func _process(_delta: float) -> void:
	genstuff()
	ungenstuff()

func playerchunk() -> Vector3:
	return ($Player.position / chunksize).floor() * chunksize

func genstuff() -> void:
	var start := Time.get_ticks_msec()
	var iters := 0
	while true:
		var centerchunk := playerchunk()
		var options: Array[Vector3] = []
		var donepoints: Dictionary[Vector3, bool] = {}
		for radius in maxradius:
			var iterres := atan(2. / radius) / 4  # TODO: figure out the correct maths for this
			for theta in Util.rangebedamned(0, TAU, iterres):
				for phi in Util.rangebedamned(-PI / 2, PI / 2, iterres):
					var point := Util.vecfloor(Vector3(cos(theta) * cos(phi), sin(phi), sin(theta) * cos(phi)) * radius)
					if point in donepoints:
						continue
					donepoints[point] = true
					var vox := point * chunksize + centerchunk
					if vox not in chunks:
						options.append(vox)
			if options:
				break
		if not options:
			break
		loadchunk(options[int(randf() * options.size())])
		iters += 1
		var timepassed := Time.get_ticks_msec() - start
		if timepassed + float(timepassed) / iters > 14:
			#print("iters:         " + str(iters))
			#print("voxels per ms: " + str(float(chunksize) ** 3 * iters / timepassed))
			#print("fps:           " + str(Engine.get_frames_per_second()))
			break

func ungenstuff() -> void:
	var centerchunk := playerchunk()
	for chunk in chunks:
		var disp := (chunk - centerchunk) / chunksize
		if disp.length() > maxradius * 1.25:
			$Chunks.remove_child(chunks[chunk])
			chunks.erase(chunk)
