#pragma language glsl3

const int kernelSize = 64;
const float radius   = 0.5;
const float bias     = 0.025;

uniform sampler2D normal_pass;
uniform sampler2D depth_pass;
uniform sampler2D noise_texture;

uniform highp mat4 projection;
uniform highp mat4 view;

uniform vec3 samples[kernelSize];

#ifdef PIXEL
vec3 ViewPosFromDepth(float depth) {
    float z=depth*2.0-1.0;

    highp vec4 clipSpacePosition = vec4(VaryingTexCoord.xy*2.0-1.0,z,1.0);
    highp vec4 viewSpacePosition = inverse(projection)*clipSpacePosition;

    viewSpacePosition/=viewSpacePosition.w;
	
    return viewSpacePosition.xyz;
}

vec4 effect(vec4 color,Image final_pass,vec2 texture_coords,vec2 screen_coords) {
	vec2 noiseScale = love_ScreenSize.xy/4.0;
	
	vec3 fragPos   = ViewPosFromDepth(Texel(depth_pass,texture_coords).x);
	vec3 normal    = Texel(normal_pass,texture_coords).rgb;
	vec3 randomVec = Texel(noise_texture,texture_coords*noiseScale).xyz;
	
	vec3 tangent   = normalize(randomVec-normal*dot(randomVec,normal));
	vec3 bitangent = cross(normal,tangent);
	highp mat3 TBN = mat3(tangent,bitangent,normal);  
	
	float occlusion = 0.0;
	for(int i=0; i<kernelSize; ++i) {
		vec3 sample_ = TBN*samples[i];
		sample_ = fragPos+sample_*radius; 
		
		vec4 offset = vec4(sample_,1.0);
		offset      = projection*offset;
		offset.xyz /= offset.w;
		offset.xyz  = offset.xyz*0.5+0.5;
		
		float sampleDepth = Texel(depth_pass,offset.xy).z;
		
		occlusion += (sampleDepth>=sample_.z+bias ? 1.0 : 0.0);

		float rangeCheck = smoothstep(0.0,1.0,radius/abs(fragPos.z-sampleDepth));
		occlusion += (sampleDepth>=sample_.z+bias ? 1.0 : 0.0)*rangeCheck; 		
	}
	
	occlusion = 1.0-(occlusion/64.0);
	
	return vec4(vec3(occlusion),1.0);
}
#endif