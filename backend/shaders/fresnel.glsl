varying vec3 f_position;

uniform mat4 view;

#ifdef VERTEX
attribute vec3 VertexNormal;

vec4 position(mat4 transform_projection,vec4 vertex_position) {
	f_position = (view*model*vertex_position).xyz;
	return projection*view*model*vertex_position;
}
#endif

#ifdef PIXEL
float effect(vec4 color,Image final_pass,vec2 texture_coords,vec2 screen_coords) {
	return f_position.z;
}
#endif