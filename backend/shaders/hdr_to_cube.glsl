#pragma language glsl3

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
const vec2 invAtan = vec2(0.1591,0.3183);

uniform sampler2D equirectangular_map;

vec2 SampleSphericalMap(vec3 v) {
    vec2 uv = vec2(atan(v.z,v.x),asin(v.y));
    uv *= invAtan;
    uv += 0.5;
    return uv;
}

vec4 effect(vec4 color,Image tex,vec2 texture_coords,vec2 screen_coords) {
	vec2 uv = SampleSphericalMap(normalize(f_position));
	return Texel(equirectangular_map,uv);
}
#endif