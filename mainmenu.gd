extends AnimatedSprite2D
@onready var thebackground = get_node("../Background")
@onready var the_http_request = get_node("../Control/Storing")
@onready var username_input_registration = get_node("../Control/Username/UsernameRegistered")
@onready var password_input_registration = get_node("../Control/Password/PasswordRegistered")
@onready var username_input_login = get_node("../Control/Username/UsernameLogin")
@onready var password_input_login = get_node("../Control/Password/PasswordLogin")
@onready var name_input = get_node("../Control/Name/NameRegistered")
@onready var age_input = get_node("../Control/Age/AgeRegistered")

@onready var submitregistration = get_node("../Control/SubmitRegistration")
@onready var submitlogin = get_node("../Control/SubmitLogin")
@onready var registerbutton=get_node("../Control/RegistrationButton")

@onready var username_text_field_registration = get_node("../Control/Username")
@onready var password_text_field_registration = get_node("../Control/Password")
@onready var username_text_field_login = get_node("../Control/Username")
@onready var password_text_field_login = get_node("../Control/Password")
@onready var name_text_field = get_node("../Control/Name")
@onready var age_text_field = get_node("../Control/Age")


@onready var incorrectCreds = get_node("../Control/LoginErrorMessage")
@onready var missingcreds = get_node("../Control/MissingCreds")
@onready var allfieldsrequired = get_node("../Control/AllFieldsRequired")
@onready var agemustbeanumber = get_node("../Control/AgeMustBeANumber")

@onready var smalllevel1button = get_node("../Control/levelnode2D/smallLevel1Button")
@onready var smalllevel2button = get_node("../Control/levelnode2D/smallLevel2Button")
@onready var smalllevel3button = get_node("../Control/levelnode2D/smallLevel3Button")
@onready var level_buttons = [smalllevel1button,smalllevel2button,smalllevel3button]
@onready var logout=get_node("../Control/Logout")
@onready var logo=get_node("../Control/Logo")

@onready var switchtologin=get_node("../Control/Switchtologin")
@onready var music=get_node("../Control/mainmenumusic")
var start_position = Vector2()
var is_swiping=false
var current_level_index=0
var is_main_menu: bool = false
func _ready():
	music.play()
	logo.visible=false
	switchtologin.visible=false
	thebackground.stop()
	if Global.logo==0:
		switchtologin.visible=false
		username_text_field_login.visible=false
		username_input_login.visible = false
		password_text_field_login.visible=false
		password_input_login.visible = false
		logo.visible=true
		logo.position=Vector2(0,-33)
		logo.scale=Vector2(9,6.7)
		var timer = Timer.new()
		timer.one_shot=true
		timer.wait_time=3
		timer.connect("timeout",Callable(self,"_on_logo_timeout"))
		add_child(timer)
		timer.start()
		Global.logo=1
	if Global.logged_in:
		music.play()
		switchtologin.visible=false
		username_text_field_login.visible=false
		username_input_login.visible = false
		password_text_field_login.visible=false
		password_input_login.visible = false
		submitlogin.visible = false
		registerbutton.visible=false
		_main_menu()
	else:
		switchtologin.visible=false
		logout.visible=false
		thebackground.visible=true
		thebackground.play()
		smalllevel1button.visible=false
		smalllevel2button.visible=false
		smalllevel3button.visible=false
		agemustbeanumber.visible=false
		allfieldsrequired.visible=false
		missingcreds.visible=false
		incorrectCreds.visible = false
		username_text_field_registration.visible = false
		username_input_registration.visible = false
		password_text_field_registration.visible = false
		password_input_registration.visible = false
		age_text_field.visible = false
		age_input.visible = false
		name_text_field.visible = false
		name_input.visible = false
		submitregistration.visible = false
		username_text_field_login.visible=true
		username_input_login.visible = true
		password_text_field_login.visible=true
		password_input_login.visible = true
		submitlogin.visible = true
		registerbutton.visible=true
		username_input_login.placeholder_text = "Enter the username"
		password_input_login.placeholder_text = "Enter the password"

		var input_size = Vector2(300, 40)
		username_input_login.set_size(input_size)
		password_input_login.set_size(input_size)

		username_text_field_login.position = Vector2(100, 100)
		username_input_login.position = username_text_field_login.position + Vector2(-90, -80)
		password_text_field_login.position = username_text_field_login.position + Vector2(0, 100)
		password_input_login.position = password_text_field_login.position + Vector2(-90, -180)

		registerbutton.position=password_input_login.position+Vector2(100,500)
		submitlogin.position = registerbutton.position + Vector2(150, 0)
		registerbutton.scale=Vector2(3,3)
		submitlogin.scale=Vector2(1.75,2)
		if registerbutton.is_connected("pressed",Callable(self,"_on_register_pressed")):
			registerbutton.disconnect("pressed",Callable(self,"_on_register_pressed")) 
		registerbutton.connect("pressed",Callable(self,"_on_register_pressed"))
		if submitlogin.is_connected("pressed", Callable(self, "_on_submit_login_pressed")):
			submitlogin.disconnect("pressed", Callable(self, "_on_submit_login_pressed"))
		submitlogin.connect("pressed", Callable(self, "_on_submit_login_pressed"))
		if the_http_request.is_connected("request_completed", Callable(self, "_on_request_completed")):
			the_http_request.disconnect("request_completed", Callable(self, "_on_request_completed"))
		the_http_request.connect("request_completed", Callable(self, "_on_request_completed"))


func _on_logo_timeout():
	logo.visible=false
	_ready()
func _on_submit_registration_pressed():
	missingcreds.visible=false
	allfieldsrequired.visible=false
	agemustbeanumber.visible=false
	var username = username_input_registration.text.strip_edges()
	var password = password_input_registration.text.strip_edges()
	var name = name_input.text.strip_edges()
	var age = age_input.text.strip_edges()
	if username == "" or password == "" or name == "" or age == "":
		allfieldsrequired.visible=true
		return
	if not is_valid_integer(age):
		agemustbeanumber.visible=true
		return
	var data = {
		"username": username,
		"password": password,
		"name": name,
		"age": int(age),
		"level1completed":0,
		"level2completed":0,
		"level3completed":0
	}
	var json_data = serialize_to_json(data)
	var headers = ["Content-Type: application/json","Accept: application/json"]
	the_http_request.request("http://127.0.0.1:5000/register", headers,  HTTPClient.METHOD_POST, json_data)

func _on_submit_login_pressed():
	missingcreds.visible=false
	var username = username_input_login.text.strip_edges()
	var password = password_input_login.text.strip_edges()

	if username == "" or password == "":
		missingcreds.visible=true
		return
	Global.player_username=username
	Global.player_password=password
	var data = {
		"username": username,
		"password": password
	}
	var json_data = serialize_to_json(data)
	var headers = ["Content-Type: application/json"]
	the_http_request.request("http://127.0.0.1:5000/login", headers, HTTPClient.METHOD_POST, json_data)


func _on_request_completed(result, response_code, headers, body):
	incorrectCreds.visible=false
	var response_text = body.get_string_from_utf8()

	var response = JSON.parse_string(response_text) #parsing json data
	var invalidCreds = (response=={"error": "Invalid username or password!"})
	if(invalidCreds):
		incorrectCreds.visible = true
		incorrectCreds.position
		
	if response_code == 200:#if successful
		
		if response['message'] == "Registration successful!":
			_switch_to_login_screen()
		elif response['message'] == "Login successful!":
			
			Global.logged_in=true
			Global.level1completed=response["level1completed"]
			Global.level2completed=response["level2completed"]
			Global.level3completed=response["level3completed"]
			_main_menu()
	else:
		if(response_code==400):
			print("Username exists!")
		print("Failed with code:", response_code)


func serialize_to_json(data: Dictionary) -> String: #converting data to json
	var json = "{"
	for key in data.keys():
		var value = data[key]
		if typeof(value) == TYPE_STRING:
			json += '"' + str(key) + '": "' + str(value) + '", '
		else:
			json += '"' + str(key) + '": ' + str(value) + ", "
	json = json.substr(0, json.length() - 2) + "}"  
	return json

func is_valid_integer(value: String) -> bool:
	return value.is_valid_float() and int(value) == float(value)

func _switch_to_login_screen():
	switchtologin.visible=false
	username_text_field_registration.visible = false
	username_input_registration.visible = false
	password_text_field_registration.visible = false
	password_input_registration.visible = false
	age_text_field.visible = false
	age_input.visible = false
	name_text_field.visible = false
	name_input.visible = false
	submitregistration.visible = false

	username_text_field_login.visible = true
	username_input_login.visible = true
	password_text_field_login.visible = true
	password_input_login.visible = true
	submitlogin.visible = true
	registerbutton.visible=true
	if registerbutton.is_connected("pressed",Callable(self,"_on_register_pressed")):
		registerbutton.disconnect("pressed",Callable(self,"_on_register_pressed")) 
	registerbutton.connect("pressed",Callable(self,"_on_register_pressed"))

	username_input_login.placeholder_text = "Enter the username"
	password_input_login.placeholder_text = "Enter the password"
	var data = {
		"username": username_input_login,
		"password": password_input_login
	}
	var json_data = serialize_to_json(data)
	var headers = ["Content-Type: application/json"]

func _on_register_pressed():
	switchtologin.visible=true
	switchtologin.position=Vector2(280,520)
	switchtologin.scale=Vector2(1.5,1.5)
	missingcreds.visible=false
	username_text_field_login.visible = false
	username_input_login.visible = false
	password_text_field_login.visible = false
	password_input_login.visible = false
	submitlogin.visible = false
	registerbutton.visible=false
	username_text_field_registration.visible = true
	username_input_registration.visible = true
	password_text_field_registration.visible =true
	password_input_registration.visible = true
	age_text_field.visible = true
	age_input.visible = true
	name_text_field.visible = true
	name_input.visible = true
	submitregistration.visible = true
	username_input_registration.placeholder_text = "Enter the username"
	password_input_registration.placeholder_text = "Enter the password"
	name_input.placeholder_text = "Enter the name"
	age_input.placeholder_text = "Enter the age"
	var input_size = Vector2(300, 40)
	username_input_registration.set_size(input_size)
	password_input_registration.set_size(input_size)
	name_input.set_size(input_size)
	age_input.set_size(input_size)

	username_text_field_registration.position = Vector2(100, 100)
	username_input_registration.position = username_text_field_registration.position + Vector2(-90, -80)
	password_text_field_registration.position = username_text_field_registration.position + Vector2(0, 100)
	password_input_registration.position = password_text_field_registration.position + Vector2(-90, -180)

	name_text_field.position = password_text_field_registration.position + Vector2(0, 100)
	name_input.position = name_text_field.position + Vector2(-90, -280)
#
	age_text_field.position = name_text_field.position + Vector2(0, 100)
	age_input.position = age_text_field.position + Vector2(-90, -380)

	submitregistration.position = age_input.position + Vector2(100, 500)
	submitregistration.scale=Vector2(2,2)
	if switchtologin.is_connected("pressed",Callable(self,"_switch_to_login_screen")):
			switchtologin.disconnect("pressed",Callable(self,"_switch_to_login_screen")) 
	switchtologin.connect("pressed",Callable(self,"_switch_to_login_screen"))
	if submitregistration.is_connected("pressed",Callable(self,"_on_submit_registration_pressed")):
		submitregistration.disconnect("pressed",Callable(self,"_on_submit_registration_pressed")) 
	submitregistration.connect("pressed", Callable(self, "_on_submit_registration_pressed"))
func arrange_buttons():
	for i in range(level_buttons.size()):
		level_buttons[i].position=Vector2(340+i*440,250)
func update_buttons_position():
	for i in range(level_buttons.size()):
		level_buttons[i].position=Vector2((i-current_level_index)*440+340,250)
	
func _main_menu():
	thebackground.visible=true
	thebackground.play()
	username_text_field_login.visible = false
	username_input_login.visible = false
	password_text_field_login.visible = false
	password_input_login.visible = false
	submitlogin.visible = false
	registerbutton.visible=false
	var levelmessage= get_node("../Control/Levelmessage")
	levelmessage.visible=true
	levelmessage.scale=Vector2(3,3)
	levelmessage.position=Vector2(350,0)
	smalllevel1button.visible=true
	smalllevel2button.visible= (Global.level1completed==1)
	smalllevel3button.visible=(Global.level2completed==1)
	smalllevel1button.position=Vector2(340,250)
	smalllevel2button.position=Vector2(780,250)
	smalllevel3button.position=Vector2(1220,250)
	smalllevel1button.scale=Vector2(10,10)
	smalllevel2button.scale=Vector2(10,10)
	smalllevel3button.scale=Vector2(10,10)
	arrange_buttons()
	set_process_input(true)
	arrange_buttons()
	set_process_input(true)
	smalllevel1button.connect("pressed",Callable(self,"trigger_level1"))
	smalllevel2button.connect("pressed",Callable(self,"trigger_level2"))
	smalllevel3button.connect("pressed",Callable(self,"trigger_level3"))
	
	logout.visible=true
	logout.scale=Vector2(3,3)
	logout.position=Vector2(500,500)
	logout.connect("pressed",Callable(self,"_on_logout_pressed"))

func _on_logout_pressed():
	Global.player_username=""
	Global.player_password=""
	Global.logged_in=false
	smalllevel1button.visible=false
	smalllevel2button.visible=false
	smalllevel3button.visible=false
	username_input_login.text=""
	password_input_login.text=""
	_ready()

func _input(event):#siping function, only swipes left for now. For swiping through levels
	if event is InputEventScreenDrag:
		if not is_swiping:
			start_position=event.position
			is_swiping=true
		else:
			var delta=event.position.x-start_position.x
			if abs(delta)>100:
				if delta<0 and current_level_index<level_buttons.size() - 1:
					current_level_index+=1
					update_buttons_position()
				elif delta>0 and current_level_index>level_buttons.size() - 1:
					current_level_index-=1
					update_buttons_position()
				is_swiping=false
	elif event is InputEventScreenTouch and event.is_released():
		is_swiping=false
func trigger_level1():
	smalllevel1button.visible=false
	smalllevel2button.visible=false
	smalllevel3button.visible=false
	thebackground.visible=false
	thebackground.stop()
	var level1 = load("res://src/level_1.tscn")
	get_tree().change_scene_to_packed(level1)
func trigger_level2():
	smalllevel1button.visible=false
	smalllevel2button.visible=false
	smalllevel3button.visible=false
	thebackground.visible=false
	thebackground.stop()
	var level2 = load("res://src/level_2.tscn")
	get_tree().change_scene_to_packed(level2)
func trigger_level3():
	smalllevel1button.visible=false
	smalllevel2button.visible=false
	smalllevel3button.visible=false
	thebackground.visible=false
	thebackground.stop()
	var level3 = load("res://src/level_3.tscn")
	get_tree().change_scene_to_packed(level3)
