#pragma language glsl3

/*
love_Canvases[0] - Albedo
love_Canvases[1] - Position
love_Canvases[2] - Normal
*/

varying vec3 f_normal;
varying vec3 f_position;
flat varying float material_id;

uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;

uniform sampler2D albedo_map;
uniform int current_material;

#ifdef VERTEX
attribute vec3 VertexNormal;
attribute float MaterialId;
attribute vec4 JointIds;
attribute vec4 JointWeights;

vec4 position(mat4 transform_projection,vec4 vertex_position) {
	f_position = (view*model*vertex_position).xyz;
	f_normal   = (view*model*vec4(VertexNormal,0.0)).xyz;
	material_id = MaterialId;
	
	return projection*view*model*vertex_position;
}
#endif

#ifdef PIXEL
void effect() {
	if (material_id!=current_material)
		discard;
	
	vec4 albedo=texture2D(albedo_map,VaryingTexCoord.rg)*VaryingColor
	
	love_Canvases[0] = albedo;
	love_Canvases[1] = vec4(f_position,albedo.a);
	love_Canvases[2] = vec4(f_normal,albedo.a);
}
#endif