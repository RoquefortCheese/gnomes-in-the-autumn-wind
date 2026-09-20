extends Node3D
class_name Chunk

const cardinals = [Vector3.UP, Vector3.DOWN, Vector3.RIGHT, Vector3.LEFT, Vector3.FORWARD, Vector3.BACK]
const bases = {
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

func create(world: World, pos: Vector3):
	self.world = world
	self.pos = pos
	lettherebeland()
	lettherebegnomes()

func lettherebeland():
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var empty = true
	for x in range(pos.x, pos.x + World.chunksize):
		for y in range(pos.y, pos.y + World.chunksize):
			for z in range(pos.z, pos.z + World.chunksize):
				var point = Vector3(x, y, z)
				if world.voxat(point) != World.Vox.AIR:
					for cardinal in cardinals:
						if world.voxat(point + cardinal) == World.Vox.AIR:
							var basis = bases[cardinal]
							var origin = point + Vector3.ONE / 2. + cardinal / 2.
							st.append_from(facemesh, 0, Transform3D(basis, origin))
							empty = false
	if not empty:
		st.set_material(material)
		$Terrain.mesh = st.commit()
		$Terrain.create_trimesh_collision()

func lettherebegnomes():
	if randf() < 2 ** -6.:
		for attempt in 256:
			var point = pos + floor(Util.randv3(World.chunksize))
			if world.voxat(point) != World.Vox.AIR:
				continue
			if world.voxat(point + Vector3.UP) != World.Vox.AIR:
				continue
			while point.y >= pos.y and world.voxat(point) == World.Vox.AIR:
				point.y -= 1
			if point.y < pos.y:
				continue
			point.y += 1
			var gnome = load("res://gnome.tscn").instantiate()
			gnome.position = point + Util.posheight(Vector2.ONE * 0.5)
			add_child(gnome)
			world.gnomes.append(gnome)
			gnome.create()
			break
