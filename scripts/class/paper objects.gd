@abstract
extends Resource
class_name PaperObject
var object_name:StringName
var display_name:String
var action_menu:PackedStringArray
var description:String
var property:Array[Dictionary]
var user_data:Dictionary
var icon:String = "uid://ch11sian14j3n"


func add_property(name:String,value,type:Variant.Type = TYPE_NIL,hint:String="") ->Error:
	const excluded_type = [TYPE_ARRAY,TYPE_MAX,TYPE_NODE_PATH,TYPE_RID,TYPE_DICTIONARY]
	if has_meta("property_"+name) and not type == TYPE_NIL:
		return Error.ERR_ALREADY_EXISTS
	else :
		if not type == TYPE_NIL:
			set_meta("property_"+name,true)
	var template = {}
	if type in excluded_type:
		return Error.ERR_SKIP
	if type > TYPE_MAX:
		return Error.ERR_INVALID_PARAMETER
	template.name = name
	template.value = type_convert(value,type)
	if type == TYPE_NIL and value is String:
		template.value = value
	template.type = type
	template.hint = hint
	property.append(template)
	return Error.OK
