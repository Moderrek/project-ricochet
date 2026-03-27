extends Node

var fallback_url: String = "http://127.0.0.1:8080"
var base_url: String = ""

func _ready() -> void:
	_setup_environment()

func fetch_news(on_success: Callable, on_error: Callable) -> void:
	# TODO: reuse HTTPRequest
	var request = HTTPRequest.new()
	add_child(request)

	request.request_completed.connect(func(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
		request.queue_free() 
		
		if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
			var json = JSON.new()
			if json.parse(body.get_string_from_utf8()) == OK:
				if on_success and on_success.is_valid():
					on_success.call(json.get_data())
			else:
				if on_error and on_error.is_valid():
					on_error.call("Failed to parse JSON.")
		else:
			if on_error and on_error.is_valid():
				on_error.call("Connection ERROR. Code: " + str(response_code))
	)
	
	var url = base_url + "/api/news"
	var error = request.request(url)
	
	if error != OK:
		request.queue_free()
		if on_error and on_error.is_valid():
			on_error.call("Failed to initialize HTTP connection.")

func _setup_environment() -> void:
	if OS.has_feature("editor"):
		base_url = "http://127.0.0.1:8080"
		print("[NetworkManager] Development Environment (", base_url, ")")
	elif OS.has_feature("web"):
		if JavaScriptBridge.get_interface("window"):
			base_url = JavaScriptBridge.eval("window.location.origin")
			print("[NetworkManager] Web Production Environment (", base_url, ")")
		else:
			base_url = ""
	else:
		base_url = fallback_url
