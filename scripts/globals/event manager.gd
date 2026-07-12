extends Node

func add_hook(hook_name:StringName,hook_func:Callable=Callable()):
	if not has_meta(hook_name) or not get_meta(hook_name) is Array:
		set_meta(hook_name,[])
		if hook_func.is_valid():
			get_meta(hook_name).append(hook_func) 
	else:
		if hook_func.is_valid():
			get_meta(hook_name).append(hook_func)



func call_hook(hook_name:StringName,...args):
	if has_meta(hook_name) and typeof(get_meta(hook_name)) == TYPE_ARRAY:
		for hook in get_meta(hook_name):
			if typeof(hook) == TYPE_CALLABLE:
				hook.callv(args)

func delete_hook(hook_name:StringName):
	if has_meta(hook_name):
		set_meta(hook_name,null)
