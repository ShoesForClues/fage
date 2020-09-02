#pragma language glsl3

uniform samplerCube environment_map;

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
const float PI = 3.14159265359;

vec4 effect(vec4 color,Image tex,vec2 texture_coords,vec2 screen_coords) {
	vec3 N = normalize(f_position);
	
	vec3 irradiance = vec3(0.0);
	
	vec3 up    = vec3(0.0,1.0,0.0);
	vec3 right = cross(up,N);
	up         = cross(N,right);

	float sampleDelta = 0.025;
	float nrSamples = 0.0;
	
	for (float phi=0.0; phi<2.0*PI; phi+=sampleDelta) {
		for(float theta=0.0; theta<0.5*PI; theta+=sampleDelta) {
			// spherical to cartesian (in tangent space)
			vec3 tangentSample = vec3(sin(theta)*cos(phi),sin(theta)*sin(phi),cos(theta));
			// tangent space to world
			vec3 sampleVec = tangentSample.x*right+tangentSample.y*up+tangentSample.z*N; 

			irradiance += Texel(environment_map,sampleVec).rgb*cos(theta)*sin(theta);
			nrSamples++;
		}
	}
	
	irradiance = PI*irradiance*(1.0/float(nrSamples));
	
	return vec4(irradiance,1.0);
}
#endif