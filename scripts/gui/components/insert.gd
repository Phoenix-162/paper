extends Window
const max_icon_width = 20
signal insert(object:PaperObject)
var root:TreeItem
var objects_regsitry:Variant = {}
func _ready() -> void:
	root = %Tree.create_item()
	var make_tree:Callable = func (regist:Dictionary,tree:TreeItem,self_func:Callable,plugin:String=""):
		for key in regist.keys():
			if regist[key] is PaperObject:
				var item = tree.create_child()
				item.set_text(0,regist[key].display_name)
				item.set_icon_max_width(0,max_icon_width)
				item.set_icon(0,load(regist[key].icon))
				item.set_metadata(0,{obj = regist[key],})
			if regist[key] is Dictionary:
				var folder = tree.create_child()
				folder.set_text(0,key)
				folder.set_metadata(0,{})
				self_func.call(regist[key],folder,self_func,plugin)
	var set_nested = func (dict: Dictionary, path: Array,value:PaperObject):
		if path.is_empty():
			return
		var current = dict
		for i in range(path.size() - 1):
			var key = path[i]
			if not current.has(key) or not (current[key] is Dictionary):
				current[key] = {}
			current = current[key]
		current[path[-1]] = value
	close_requested.connect(func(): hide())
	for plugin in PluginManager.get_children():
		objects_regsitry[plugin.name] = {}
		var objects = PluginManager.get_objects(plugin.name)
		for object_id in PluginManager.get_objects(plugin.name):
			var path = object_id.split("/")
			if object_id.get_base_dir() == "":
				objects_regsitry[plugin.name][object_id] = objects[object_id]
				continue
			set_nested.call(objects_regsitry[plugin.name],path,objects[object_id])
	make_tree.call(objects_regsitry,root,make_tree)
func _on_cancel_pressed() -> void:
	hide()
func _on_insert_pressed() -> void:
	hide()
	insert.emit(%Tree.get_selected().get_metadata(0).obj)
func _on_tree_item_selected() -> void:
	var metadata:Dictionary = %Tree.get_selected().get_metadata(0)
	if metadata.has(&"obj"):
		%insert.disabled = false
		%description.text = metadata.obj.description
	else :
		%insert.disabled = true
		%description.text = ""
func _on_about_to_popup() -> void:
	%description.text = ""
