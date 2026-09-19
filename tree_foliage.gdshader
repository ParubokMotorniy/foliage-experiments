shader_type spatial;
render_mode depth_prepass_alpha, cull_disabled, world_vertex_coords;//, diffuse_toon;

uniform sampler2D texture_albedo : source_color;
uniform sampler2D texture_alpha : source_color;
uniform sampler2D normal_texture : hint_normal;
uniform sampler2D roughness_texture : hint_default_black;
uniform sampler2D sss_texture : hint_default_black;

uniform float sway_speed = 1.0;
uniform float sway_strength = 0.05;
uniform float sway_phase_len = 8.0;

//TODO: stable, but unrealisitc way to determine leaf side.
//prone to mesh definition, which is fucked up.
//replace with something better.
varying flat int leaf_side;

void vertex() {
	//float strength = 0.0;
    float strength = COLOR.r * sway_strength;
    VERTEX.x += sin(VERTEX.x * sway_phase_len * 1.123 + TIME * sway_speed) * strength;
    VERTEX.y += sin(VERTEX.y * sway_phase_len + TIME * sway_speed * 1.12412) * strength;
    VERTEX.z += sin(VERTEX.z * sway_phase_len * 0.9123 + TIME * sway_speed * 1.3123) * strength;
	
	leaf_side = int(dot(NORMAL, vec3(0.0,1.0,0.0)) > 0.0);
}

void fragment() {
    vec4 albedo_tex = texture(texture_albedo, UV);
	NORMAL_MAP = texture(normal_texture, UV).rgb;
    ALBEDO = albedo_tex.rgb;
    //ALBEDO = vec3(UV, 1.0);
    //ALBEDO = vec3(float(leaf_side),0.0, 0.0);
    ALPHA = texture(texture_alpha, UV).r;
	
	float sampled_roughness = texture(roughness_texture, UV).r;
	float actual_roughness = sampled_roughness;
	if(sampled_roughness == 0.0)
	{
		actual_roughness = 0.65;
	}
	
	vec4 sampled_sss_color = texture(sss_texture, UV).rgba;
	vec4 actual_sss_color = sampled_sss_color;
	if(sampled_sss_color == vec4(0.0, 0.0, 0.0, 1.0))
	{
		actual_sss_color = vec4(0.2, 0.32, 0.12, 1.0);
	}
	
	
	if(leaf_side == 1)
	{
		//top leaf side, waxy
    	METALLIC = 0.01;
    	ROUGHNESS = actual_roughness * 0.5;
    	SSS_TRANSMITTANCE_COLOR = actual_sss_color;
		SSS_STRENGTH = 0.01;
		//SSS_TRANSMITTANCE_DEPTH = 
		RIM = 0.05;
	}
	else
	{
		//bottom leaf side, slightly harsh
    	METALLIC = 0.0;
    	ROUGHNESS = actual_roughness;
    	SSS_TRANSMITTANCE_COLOR = actual_sss_color;
		SSS_STRENGTH = 0.05;
		//SSS_TRANSMITTANCE_DEPTH = 
		RIM = 0.1;
	}
}
//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
