#pragma language glsl3

varying vec3 f_normal;
varying vec3 f_position;
flat varying float f_material;

uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;

#ifdef VERTEX
attribute vec3 VertexNormal;
attribute float MaterialId;

vec4 position(mat4 transform_projection,vec4 vertex_position) {
	f_position = (view*model*vertex_position).xyz;
	f_normal   = (view*model*vec4(VertexNormal,0.0)).xyz;
	f_material = MaterialId;
	
	return projection*view*model*vertex_position;
}
#endif