#pragma language glsl3

varying vec3 f_normal;
varying vec3 f_position;
flat varying float f_material;

uniform sampler2D albedo_map;
uniform sampler2D metalic_map;
uniform sampler2D rough_map;

uniform samplerCube reflection_map;

uniform vec3 albedo;
uniform float metalic;
uniform float roughness;

uniform int current_material;

uniform vec3 camera_position;

uniform highp mat4 projection;
uniform highp mat4 view;

#ifdef PIXEL
void effect() {
	if (int(f_material)!=current_material)
		discard;
	
	vec3 world_position=(inverse(view)*vec4(f_position,1.0)).xyz;
	vec3 world_normal=(inverse(view)*vec4(f_normal,0.0)).xyz;
	
	vec3 I = normalize(world_position-camera_position);
    vec3 R = reflect(I,normalize(world_normal));
	
	vec4 albedo=Texel(albedo_map,VaryingTexCoord.rg)*VaryingColor;
	vec4 reflection=mix(vec4(1.0),Texel(reflection_map,R),metalic);
	
	love_Canvases[0] = albedo*reflection;
	love_Canvases[1] = vec4(f_normal,albedo.a);
	//love_Canvases[2] = vec4(f_position.z);
}
#endif