extends Control

const STORY_PATH := "res://data/chapters/chapter_01.json"
const SAVE_PATH := "user://ashen_oath_save.json"

@onready var panel_text: Label = $Margin/Layout/Panel/PanelText
@onready var speaker: Label = $Margin/Layout/Speaker
@onready var narrative: Label = $Margin/Layout/Narrative
@onready var choices: VBoxContainer = $Margin/Layout/Choices
@onready var restart_button: Button = $Margin/Layout/Footer/Restart

var nodes: Dictionary = {}
var state := {"flags": {}, "stats": {}}
var current_node_id := "checkpoint_arrival"

func _ready() -> void:
	restart_button.pressed.connect(restart)
	load_story()
	load_progress()
	show_node(current_node_id)

func load_story() -> void:
	var file := FileAccess.open(STORY_PATH, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	for node in parsed.get("nodes", []):
		nodes[node["id"]] = node

func show_node(node_id: String) -> void:
	current_node_id = node_id
	var node: Dictionary = nodes[node_id]
	panel_text.text = node.get("panel_description", "Artwork placeholder")
	speaker.text = node.get("speaker", "")
	narrative.text = node.get("text", "")
	for child in choices.get_children():
		child.queue_free()
	for choice in node.get("choices", []):
		if conditions_met(choice.get("requires", {})):
			var button := Button.new()
			button.text = choice["text"]
			button.custom_minimum_size.y = 72
			button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			button.pressed.connect(select_choice.bind(choice))
			choices.add_child(button)
	if node.has("ending"):
		var ending := Label.new()
		ending.text = "ENDING — " + str(node["ending"])
		ending.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		choices.add_child(ending)
	save_progress()

func select_choice(choice: Dictionary) -> void:
	apply_effects(choice.get("effects", {}))
	show_node(choice["next"])

func apply_effects(effects: Dictionary) -> void:
	for key in effects:
		var value = effects[key]
		if value is int or value is float:
			state["stats"][key] = state["stats"].get(key, 0) + value
		else:
			state["flags"][key] = value

func conditions_met(required: Dictionary) -> bool:
	for key in required:
		if state["flags"].get(key, state["stats"].get(key)) != required[key]:
			return false
	return true

func save_progress() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify({"node": current_node_id, "state": state}))

func load_progress() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var saved = JSON.parse_string(file.get_as_text())
	if saved is Dictionary and nodes.has(saved.get("node", "")):
		current_node_id = saved["node"]
		state = saved.get("state", state)

func restart() -> void:
	state = {"flags": {}, "stats": {}}
	current_node_id = "checkpoint_arrival"
	show_node(current_node_id)

