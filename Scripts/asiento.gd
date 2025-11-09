extends Control
class_name Asiento

@onready var state_panel: Panel = %State

enum AsientoState { NO_OCUPADO, OCUPADO, OVERBOOKED }

const COLORS = {
	AsientoState.NO_OCUPADO: Color("#1E1E1E"),
	AsientoState.OCUPADO: Color("3A3A3A"), 
	AsientoState.OVERBOOKED: Color("007F5F")
}
const OUTLINE_COLORS = {
	Aerolinea.Type.NORMAL: Color("#2E2E2E"),
	Aerolinea.Type.VIP: Color("#C9A227"),
	Aerolinea.Type.EMPTY: Color.TRANSPARENT
}

var avion: Avion = null

var id_asiento: String = ""
var tipo: Aerolinea.Type = Aerolinea.Type.NORMAL
var pos: Vector2i = Vector2i.ZERO

var num_requests: int = 0
var state: AsientoState = AsientoState.NO_OCUPADO

func set_data(data: Dictionary) -> void:
	id_asiento = data["id"]
	tipo = data["tipo"]
	pos = data["pos"]
	avion = data["avion"]
	update_ui()

func set_pasajero(pasajero: Pasajero) -> void:
	num_requests += 1
	
	if num_requests == 1:
		state = AsientoState.OCUPADO
		avion.add_pasajero(self, pasajero)
	elif num_requests >= 2:
		state = AsientoState.OVERBOOKED
	
	call_deferred("update_ui")

func update_ui() -> void:
	state_panel.get_theme_stylebox("panel").bg_color = COLORS[state]
	state_panel.get_theme_stylebox("panel").border_color = OUTLINE_COLORS[tipo]
	state_panel.visible = tipo != Aerolinea.Type.EMPTY

func _to_string():
	return id_asiento
