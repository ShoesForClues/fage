#pragma language glsl3

uniform samplerCube sky_map;

uniform highp mat4 projection;
uniform highp mat4 view;

varying vec3 f_position;

#ifdef VERTEX
vec4 position(highp mat4 transform_projection,highp vec4 vertex_position) {
	f_position=vertex_position.xyz;
	return projection*view*vertex_position;
}
#endif

#ifdef PIXEL
vec4 effect(vec4 color,Image tex,vec2 texture_coords,vec2 screen_coords) {
	vec3 envColor = Texel(sky_map,f_position).rgb;
	
	envColor = envColor/(envColor+vec3(1.0));
	envColor = pow(envColor,vec3(1.0/2.2));
	
	return vec4(envColor,1.0);
}
#endif