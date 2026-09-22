shader_type spatial;
render_mode depth_prepass_alpha, cull_disabled, world_vertex_coords;//, diffuse_toon;

uniform sampler2D texture_albedo : source_color;
uniform sampler2D texture_alpha : source_color;
uniform sampler2D normal_texture : hint_normal;
uniform sampler2D roughness_texture;

uniform float sway_speed = 1.0;
uniform float sway_strength = 0.05;
uniform float sway_phase_len = 8.0;

void vertex() {
    float strength = COLOR.r * sway_strength;
    VERTEX.x += sin(VERTEX.x * sway_phase_len * 1.123 + TIME * sway_speed) * strength;
    VERTEX.y += sin(VERTEX.y * sway_phase_len + TIME * sway_speed * 1.12412) * strength;
    VERTEX.z += sin(VERTEX.z * sway_phase_len * 0.9123 + TIME * sway_speed * 1.3123) * strength;
}

void fragment() {
    vec4 albedo_tex = texture(texture_albedo, UV);
	NORMAL_MAP = texture(normal_texture, UV).rgb;
    ALBEDO = albedo_tex.rgb;
    ALPHA = texture(texture_alpha, UV).r;
    METALLIC = 0.0;
    ROUGHNESS = texture(roughness_texture, UV).r;;
}
//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
