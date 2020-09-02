#pragma language glsl3

uniform mat4 projection;

#ifdef PIXEL
vec3 ViewPosFromDepth(float depth) {
    float z=depth*2.0-1.0;

    highp vec4 clipSpacePosition = vec4(VaryingTexCoord.xy*2.0-1.0,z,1.0);
    highp vec4 viewSpacePosition = inverse(projection)*clipSpacePosition;

    viewSpacePosition/=viewSpacePosition.w;
	
    return viewSpacePosition.xyz;
}

vec4 effect(vec4 color,Image depth_pass,vec2 texture_coords,vec2 screen_coords) {
	return vec4(ViewPosFromDepth(Texel(depth_pass,texture_coords).x),1.0);
}
#endif