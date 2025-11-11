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
var aerolinea: Aerolinea = null

var id_asiento: String = ""
var tipo: Aerolinea.Type = Aerolinea.Type.NORMAL
var pos: Vector2i = Vector2i.ZERO

var num_requests: int = 0
var state: AsientoState = AsientoState.NO_OCUPADO

var boleto: Boleto = null

var pasajeros_id: Array[String] = []

func set_data(data: Dictionary) -> void:
	id_asiento = data["id"]
	tipo = data["tipo"]
	pos = data["pos"]
	avion = data["avion"]
	update_ui()

func set_pasajero(pasajero: Pasajero) -> void:
	num_requests += 1
	pasajeros_id.append(pasajero.id_pasajero)
	
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

# En Asiento.gd
func _on_mouse_entered():
	update_border(true)
	aerolinea.asiento_hover.text = id_asiento
	aerolinea.mover_boletos_al_frente_por_asiento(self)
	
	# Resaltar los boletos (opcional)
	for id in pasajeros_id:
		if aerolinea.boletos.has(id):
			aerolinea.boletos[id].panel.get_theme_stylebox("panel").bg_color = Color("4e4e4e99")

func _on_mouse_exited():
	update_border(false)
	aerolinea.asiento_hover.text = ""
	for id in pasajeros_id:
		if aerolinea.boletos.has(id):
			aerolinea.boletos[id].panel.get_theme_stylebox("panel").bg_color = Color("1a1a1a99")

func update_border(active: bool) -> void:
	state_panel.get_theme_stylebox("panel").border_color = Color.WHITE if active else OUTLINE_COLORS[tipo]
