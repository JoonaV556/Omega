class_name ContextMenu
extends VBoxContainer


func _init(attach_to : Node, _position : Vector2 = Vector2.ZERO) -> void:
    self.position = _position
    self.name = "context menu"
    attach_to.add_child(self)


## Connect to signal for adding behavior for the button
func add_button(title : String) -> Signal:
    var button : Button = Button.new()
    button.name = title
    button.text = title
    button.alignment = HORIZONTAL_ALIGNMENT_LEFT
    add_child(button)

    return button.pressed

