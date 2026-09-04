# 1. Create a custom router script (e.g., MyRouter.gd)
extends Node
class_name MyExampleRouter


@onready var file_dialog: FileDialog = $"../FileDialog"
const FILE_DIALOG_SIZE := Vector2i(500,400)
var fileDialogRouter := HttpRouter.new("/fileDialog/",{
	"get": func(request: HttpRequest, response: HttpResponse):
		var monitor_size: Vector2i = DisplayServer.screen_get_size(DisplayServer.window_get_current_screen())
		var center = monitor_size / 2
		var size_half = FILE_DIALOG_SIZE / 2
		#file_dialog.popup(Rect2i(monitor_size - size_half,monitor_size + size_half))
		
		var semaphore = Semaphore.new()
		var selected_path = ""
		var result_container: Array[String] = [""]
		  
		Callable(func():
			var on_file = func(path):
				result_container[0] = path
				semaphore.post()
				 
			var on_cancel = func():
				semaphore.post()
				
			file_dialog.file_selected.connect(on_file, CONNECT_ONE_SHOT)
			file_dialog.canceled.connect(on_cancel, CONNECT_ONE_SHOT)
			
			file_dialog.popup_centered(FILE_DIALOG_SIZE)
		).call_deferred()
		
		semaphore.wait()
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
		if result_container[0]:
			response.send(200,result_container[0])
		else:
			response.send(200,"")
		return true
})

var killRouter := HttpRouter.new("/kill/",{
	"get": func(request: HttpRequest, response: HttpResponse):
		response.send(200)
		get_tree().quit()
		return true
})

var pingRouter := HttpRouter.new("/",{
	"get": func(request: HttpRequest, response: HttpResponse):
		response.send(200,"hello world")
		return true
})

func _ready() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
	var server = HttpServer.new()
	server.port = 8080
	server.register_router(pingRouter)
	server.register_router(fileDialogRouter)
	server.register_router(killRouter)
	add_child(server)
	server.start()
