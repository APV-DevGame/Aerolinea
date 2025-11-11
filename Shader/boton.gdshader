shader_type canvas_item;

// Color que reemplazará completamente la textura
uniform vec4 force_color : source_color = vec4(1.0);

void fragment() {
	// Obtiene el color original de la textura
	vec4 texture_color = texture(TEXTURE, UV);
	
	// Usa el alpha de la textura original pero reemplaza completamente el color RGB
	COLOR = vec4(force_color.rgb, texture_color.a * force_color.a);
}