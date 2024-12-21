extends Object

class_name FileHelper

static func listDir(path: String, is_folder: bool) -> Array:
	var results = []
	var dir := DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var item_name = dir.get_next()
		while item_name != "":
			if dir.current_is_dir() == is_folder:
				results.append(item_name)
			item_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("Failed to open: ",path)
	return results

static func save_to_json_file(file_path, data, indent: String=""):
	var file = FileAccess.open(file_path,FileAccess.WRITE)
	var json = JSON.new()
	var string = json.stringify(data,indent)
	file.store_line(string)
	file.close()
