extends Node


var plugin_path:String:
	get:
		if OS.has_feature("editor"):
			return ProjectSettings.globalize_path("res://.godot/data/plugins")
		else:
			return OS.get_executable_path().get_base_dir()+"/plugins"


func _ready() -> void:
	if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(plugin_path)):
		DirAccess.make_dir_absolute(ProjectSettings.globalize_path(plugin_path))
	print(OS.get_executable_path().get_base_dir())
	load_plugin(plugin_path+"/core")
	


func get_objects(plugin:String) -> Dictionary[String,PaperObject]:
	var plugin_node:Node = get_node(plugin)
	return plugin_node.get_meta("obj")


func  validate(plugin:String,object:StringName=""):
	var node = get_node_or_null(plugin)
	if object == "":
		if plugin == "":
			return false
		if node == null:
			return false
		if not node.has_meta("obj"):
			return false
		if not node.get_meta("obj") is Dictionary:
			return false
	else :
		if node == null:
			return false
		if not node.has_meta("obj"):
			return false
		if not node.get_meta("obj") is Dictionary:
			return false
		if not node.get_meta("obj").has(object):
			return false
		if not node.get_meta("obj")[object] is PaperObject:
			return false
	return true
	


func load_plugin(path:String) ->Error:
	# validate if plugin has an entry point
	if FileAccess.file_exists(path+"/main.gd"):
		var plugin_node = Node.new()
		plugin_node.set_script(load(ProjectSettings.globalize_path(path+"/main.gd")))
		if "plugin_name" in plugin_node:
			plugin_node.name = plugin_node.plugin_name
			if plugin_node.plugin_name == "":
				plugin_node.queue_free()
				return Error.ERR_INVALID_DATA
		else :
			plugin_node.name =  path.split("/")[-1]
		if "plugin" in plugin_node:
			plugin_node.plugin = plugin_node
		if DirAccess.dir_exists_absolute(path+"/object"):
			var plugin_objects:Dictionary[String,PaperObject]
			var dir = DirAccess.open(path+"/object")
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if not dir.current_is_dir():
					if file_name.ends_with(".gd"):
						var path_script:String = dir.get_current_dir()+"/"+file_name
						var obj = load(path_script).new()
						if obj is PaperObject and obj.object_name != "":
							plugin_objects[obj.object_name] = obj
							obj.set_meta("plugin",plugin_node.name)
						pass
				file_name = dir.get_next()
			plugin_node.set_meta("obj",plugin_objects)
		plugin_node.set_meta("path",path)
		add_child(plugin_node)
		return Error.OK
	return Error.ERR_FILE_BAD_PATH
