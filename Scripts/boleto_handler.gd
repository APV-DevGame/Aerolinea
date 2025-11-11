extends Button

@onready var v_box_container = %VBoxContainer
@onready var pasajero = %Pasajero
@onready var destino = %Destino
@onready var horario = %Horario

var pasajero_id: String = ""
var tipo_asiento: String = ""

var is_vis: bool = false

func set_data(id: String, n_destino: String, n_horario: String) -> void:
	pasajero.text = id
	destino.text = n_destino
	horario.text = n_horario

func add_boleto(boleto: Boleto) -> void:
	v_box_container.add_child(boleto)
	boleto.visible = false

func _on_pressed():
	
	for child in v_box_container.get_children():
		child.visible = !is_vis
	is_vis = !is_vis
