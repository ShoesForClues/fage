#pragma language glsl3

#ifdef GL_ES
precision mediump float;
#endif

out int material_id;

uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;

#ifdef VERTEX
attribute vec3 VertexNormal;

vec4 position(mat4 transform_projection,vec4 vertex_position) {
	f_normal   = (view*model*vec4(VertexNormal,0.0)).xyz;
	f_position = (view*model*vertex_position).xyz;
	
	return projection*view*model*vertex_position;
}
#endif

#ifdef PIXEL
vec4 effect(vec4 color,Image background,vec2 texture_coords,vec2 screen_coords) {
	
}
#endif