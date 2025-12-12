#@tool
extends MeshInstance3D

@export var texture: Texture
#	set(set_base):
#		if set_base != base_sprite:
#			base_sprite = set_base
#			_assign_textures(0,mat_0)
#			_assign_textures(1,mat_1)

@export var draw_center: bool = true

@export_group("Patch Margin")
@export_range(0, 16384, 1, "suffix:px") var left : int
@export_range(0, 16384, 1, "suffix:px") var top : int
@export_range(0, 16384, 1, "suffix:px") var right : int
@export_range(0, 16384, 1, "suffix:px") var bottom : int

@export_group("Axis Stretch")
@export_enum("Stretch","Tile") var horizontal : String = "Tile"
@export_enum("Stretch","Tile") var vertical : String = "Tile"

@export_group("Transform")
@export_enum("Bottom Left", "Top Left", "Top Right", "Bottom Right") var origin : String = "Bottom Left"
@export_range(1, 100, 1,"suffix:m") var x : float = 1
#	set(set_x):
#		if set_x != meters_x:
#			meters_x = set_x
#			_create_mesh()
@export_range(1, 100, 1, "suffix:m") var y : float = 1
#	set(set_y):
#		if set_y != meters_y:
#			meters_y = set_y
#			_create_mesh()
#			_scale_y()

var uv_map = PackedVector2Array([
		Vector2(0,0),
		Vector2(1,0),
		Vector2(0,1),
		Vector2(1,1)
	])

func _ready() -> void:
	_create_mesh() #custom function

func _create_mesh():
	mesh = ArrayMesh.new()
	var row = 0
	var column = 0
	for i in range(9):
		#generate new tile
		var data = []
		data.resize(ArrayMesh.ARRAY_MAX)
		#((column/row position * size of area + offset based on size) * scale) /3 because of the 3x3 grid
		data[ArrayMesh.ARRAY_VERTEX] = PackedVector2Array([
			Vector2((column*x)*scale.x,(row*y+y)*scale.y)/3, #top left vertex
			Vector2((column*x+x)*scale.x,(row*y+y)*scale.y)/3, #top right vertex
			Vector2((column*x)*scale.x,(row*y)*scale.y)/3, #bottom left vertex
			Vector2((column*x+x)*scale.x,(row*y)*scale.y)/3 #bottom right vertex
		])
		data[ArrayMesh.ARRAY_TEX_UV] = uv_map
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP,data)
		#assign material to current tile
		var material = StandardMaterial3D.new()
		_assign_textures(i,material)
		#set next tile location
		row = row + 1
		if row == 3:
			column = column + 1
			row = 0
	#generate collision shape
	var collision_shape = mesh.create_trimesh_shape()
	$StaticBody3D/CollisionShape3D.shape = collision_shape

func _assign_textures(i,material):
	material.albedo_texture = texture
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	match horizontal:
		"Stretch": pass
		"Tile":
			material.uv1_scale.x = x
	match vertical:
		"Stretch": pass
		"Tile":
			material.uv1_scale.y = y
	mesh.surface_set_material(i,material)

func _scale_x():
	pass
#	mat_5.uv1_scale.x = scale.x

func _scale_y():
	pass
#	mat_5.uv1_scale.y = scale.y
