#pragma language glsl3

uniform sampler2D albedo_pass;
uniform sampler2D normal_pass;
//uniform sampler2D position_depth_pass;

//uniform mat4 projection;
uniform highp mat4 view;

uniform vec3 light_direction;
uniform float brightness;

#ifdef PIXEL
vec4 effect(vec4 color,Image background,vec2 texture_coords,vec2 screen_coords) {
	vec3 normal=(inverse(view)*vec4(Texel(normal_pass,texture_coords).xyz,0.0)).xyz;
	float diffuse=max(-dot(normal,light_direction),0.0);
	
	return
		Texel(albedo_pass,texture_coords)
		*vec4(vec3(mix(0.5,brightness,diffuse)),1.0);
}
#endif