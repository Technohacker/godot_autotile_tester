extends EditorInspectorPlugin

var editor: EditorInterface
var tileset: TileSet

const PATTERN = preload("res://addons/godot_autotile_tester/autotile_test_pattern.gd").AUTOTILE_PATTERN

func _init(editor):
	self.editor = editor

func can_handle(object):
	if object is TileSet:
		tileset = object.duplicate()
		return true
	else:
		return false

func parse_end():
	var ctl = VBoxContainer.new()

	for child in ctl.get_children():
		ctl.remove_child(child)

	var btn = Button.new()
	# Tileset Test
	btn.name = "AutotileTest"
	btn.text = "Test Autotiles"
	btn.connect("pressed", self, "autotile_test_btn_pressed")

	ctl.add_child(btn)

	add_custom_control(ctl)

func autotile_test_btn_pressed():
	self.editor.call_deferred("open_scene_from_path", "res://addons/godot_autotile_tester/AutotileTestPattern.tscn")
	self.call_deferred("add_autotile_pattern")

func add_autotile_pattern():
	var test_scene = self.editor.get_edited_scene_root()
	var tilemap = test_scene.get_node("TileMap") as TileMap

	tilemap.tile_set = tileset
	tilemap.clear()

	var size_set = false

	var y_offset = 0
	for tile_id in tileset.get_tiles_ids():
		if tileset.tile_get_tile_mode(tile_id) == TileSet.AUTO_TILE:
			# Autotile
			if !size_set:
				tilemap.cell_size = tileset.autotile_get_size(0)
				size_set = true

			for x in PATTERN.size():
				for y in PATTERN[x]:
					tilemap.set_cell(x, y + y_offset, tile_id)
			y_offset += PATTERN.size() + 1

	tilemap.update_bitmask_region()
