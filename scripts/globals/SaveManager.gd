extends Node

const file_signatures = "paper"
var save_path:String:
	get:
		if OS.has_feature("editor"):
			return "res://.godot/data"
		else:
			return OS.get_executable_path().get_base_dir()
var data:Dictionary = {
	project_configs = {},
	plugins = {},
}

var project_list:Array:
	set(val):
		if not FileAccess.file_exists(ProjectSettings.globalize_path(save_path)+"/list.txt"):
			var writer = FileAccess.open(ProjectSettings.globalize_path(save_path)+"/list.txt",FileAccess.WRITE)
			writer.store_string("[]")
		var file = FileAccess.open(ProjectSettings.globalize_path(save_path)+"/list.txt",FileAccess.READ_WRITE)
		var content:Array = str_to_var(file.get_as_text())
		for item in val:
			if item.begins_with("\u0001"): # remove the selced items from array
				if content.is_empty():
					continue
				content.remove_at(item.trim_prefix("\u0001").to_int())
			elif item.begins_with("\u0002"): # insert the item to selcted index
				var args:PackedStringArray = item.trim_prefix("\u0002").split("\u0002")
				content.insert(args[0].to_int(),args[1])
			else :
				content.append(item)
		#clear the file it wont overide for some reson and try ti make separt trow an error
		FileAccess.open(ProjectSettings.globalize_path(save_path)+"/list.txt",FileAccess.WRITE).close() 
		file.store_string(var_to_str(content))
			
	get:
		if not FileAccess.file_exists(ProjectSettings.globalize_path(save_path)+"/list.txt"):
			var writer = FileAccess.open(ProjectSettings.globalize_path(save_path)+"/list.txt",FileAccess.WRITE)
			writer.store_string("[]")
			writer.close()
			return[]
		else :
			var reader = FileAccess.open(ProjectSettings.globalize_path(save_path)+"/list.txt",FileAccess.READ)
			var content = reader.get_as_text()
			if content == "":
				return []
			return str_to_var(content)



func _ready() -> void:
	if not FileAccess.file_exists(ProjectSettings.globalize_path(save_path)+"/list.txt"):
		var writer = FileAccess.open(save_path+"/list.txt",FileAccess.WRITE)
		writer.store_string("[]")
		writer.close()
	if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(SaveManager.save_path+"/tmp")):
		DirAccess.make_dir_absolute(ProjectSettings.globalize_path(SaveManager.save_path+"/tmp"))



func save_project(path:String):
	var writer = FileAccess.open_compressed(path,FileAccess.WRITE,FileAccess.COMPRESSION_ZSTD)
	writer.store_buffer(file_signatures.to_ascii_buffer())
	var content = var_to_bytes(data)
	writer.store_64(hash(content))
	writer.store_buffer(content)
	project_list = [ProjectSettings.globalize_path(path)]
	writer.close()


func load_project(path:String) ->Error:
	if not FileAccess.file_exists(path):
		return Error.ERR_FILE_NOT_FOUND
	var reader = FileAccess.open_compressed(path,FileAccess.READ,FileAccess.COMPRESSION_ZSTD)
	var signatures = reader.get_buffer(file_signatures.length()).get_string_from_ascii()
	if signatures != file_signatures:
		return Error.ERR_FILE_UNRECOGNIZED
	var file_hash = reader.get_64()
	var content:PackedByteArray = reader.get_buffer(reader.get_length() - reader.get_position())
	if file_hash != hash(content):
		return Error.ERR_FILE_CORRUPT
	data = bytes_to_var(content)
	return Error.OK
