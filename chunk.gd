extends Node3D
class_name Chunk

const cardinals: Array[Vector3] = [Vector3.UP, Vector3.DOWN, Vector3.RIGHT, Vector3.LEFT, Vector3.FORWARD, Vector3.BACK]
const bases: Dictionary[Vector3, Basis] = {
	Vector3.UP: Basis(Vector3.RIGHT, Vector3.UP, Vector3.BACK),
	Vector3.DOWN: Basis(Vector3.LEFT, Vector3.DOWN, Vector3.BACK),
	Vector3.RIGHT: Basis(Vector3.FORWARD, Vector3.RIGHT, Vector3.DOWN),
	Vector3.LEFT: Basis(Vector3.BACK, Vector3.LEFT, Vector3.DOWN),
	Vector3.FORWARD: Basis(Vector3.LEFT, Vector3.FORWARD, Vector3.DOWN),
	Vector3.BACK: Basis(Vector3.RIGHT, Vector3.BACK, Vector3.DOWN)
}

@export var material: ShaderMaterial
@export var facemesh: PlaneMesh

var world: World
var pos: Vector3

func create(worlda: World, posa: Vector3) -> void:
	world = worlda
	pos = posa
	lettherebeland()
	lettherebegnomes()

func lettherebeland() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var empty := true
	for x in range(pos.x, pos.x + World.chunksize):
		for y in range(pos.y, pos.y + World.chunksize):
			for z in range(pos.z, pos.z + World.chunksize):
				var point := Vector3(x, y, z)
				if world.voxat(point) != World.Vox.AIR:
					for cardinal in cardinals:
						if world.voxat(point + cardinal) == World.Vox.AIR:
							var facebasis := bases[cardinal]
							var origin := point + Vector3.ONE / 2. + cardinal / 2.
							st.append_from(facemesh, 0, Transform3D(facebasis, origin))
							empty = false
	if not empty:
		st.set_material(material)
		$Terrain.mesh = st.commit()
		$Terrain.create_trimesh_collision()

func bringintoexistence(res: String, chance: float) -> PhysicsBody3D:
	if randf() > chance:
		return null
	for attempt in 256:
		var point := pos + Util.randv3(World.chunksize).floor()
		if world.voxat(point) != World.Vox.AIR:
			continue
		if world.voxat(point + Vector3.UP) != World.Vox.AIR:
			continue
		while point.y >= pos.y and world.voxat(point) == World.Vox.AIR:
			point.y -= 1
		if point.y < pos.y:
			continue
		point.y += 1
		var thing: PhysicsBody3D = load(res).instantiate()
		add_child(thing)
		thing.position = point + Util.posheight(Vector2.ONE * 0.5)
		return thing
	return null

func lettherebegnomes() -> void:
	var gnome: Gnome = bringintoexistence("res://gnome.tscn", 2 ** -5.)
	if gnome != null:
		gnome.create()
		world.gnomes.append(gnome)
	bringintoexistence("res://truth.tscn", 2 ** -8.)
