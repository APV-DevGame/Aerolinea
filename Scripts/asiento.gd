extends Control
class_name Asiento

enum AsientoState { OCUPADO, NO_OCUPADO, OVERBOOKED }

var id_asiento: String = ""
var state: AsientoState = AsientoState.NO_OCUPADO
var tipo: Aerolinea.Type = Aerolinea.Type.NORMAL
var pos: Vector2i = Vector2i.ZERO
