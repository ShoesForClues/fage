#pragma language glsl3

const int MAX_LIGHTS=4;
const float PI=3.14159265359;

varying highp mat3 TBN;
varying vec3 f_normal;
varying vec3 f_position;
flat varying float f_material;

uniform sampler2D albedo_map;
uniform sampler2D metal_map;
uniform sampler2D rough_map;
uniform sampler2D normal_map;
uniform sampler2D occlusion_map;
uniform samplerCube irradiance_map;
uniform samplerCube reflection_map;

uniform float metalness;
uniform float roughness;
uniform int current_material;

uniform vec3 point_light_positions[MAX_LIGHTS];
uniform vec3 point_light_colors[MAX_LIGHTS];

uniform vec3 view_position;
uniform highp mat4 projection;
uniform highp mat4 view;

float DistributionGGX(vec3 N,vec3 H,float RN) {
    float a      = RN*RN;
    float a2     = a*a;
    float NdotH  = max(dot(N,H),0.0);
    float NdotH2 = NdotH*NdotH;
	
    float num   = a2;
    float denom = (NdotH2*(a2-1.0)+1.0);
    denom = PI*denom*denom;
	
    return num/denom;
}

float GeometrySchlickGGX(float NdotV,float RN) {
    float r = (RN+1.0);
    float k = (r*r)/8.0;

    float num   = NdotV;
    float denom = NdotV*(1.0-k)+k;
	
    return num/denom;
}

float GeometrySmith(vec3 N,vec3 V,vec3 L,float RN) {
    float NdotV = max(dot(N,V),0.0);
    float NdotL = max(dot(N,L),0.0);
    float ggx2  = GeometrySchlickGGX(NdotV,RN);
    float ggx1  = GeometrySchlickGGX(NdotL,RN);
	
    return ggx1*ggx2;
}

vec3 fresnelSchlick(float cosTheta,vec3 F0) {
    return F0+(1.0-F0)*pow(1.0-cosTheta,5.0);
}

vec3 fresnelSchlickRoughness(float cosTheta,vec3 F0,float RN) {
	return F0+(max(vec3(1.0-RN),F0)-F0)*pow(1.0-cosTheta,5.0);
}

void effect() {
	if (int(f_material)!=current_material)
		discard;
	
	vec3 f_albedo=(Texel(albedo_map,VaryingTexCoord.rg)*VaryingColor).rgb;
	float opacity=(Texel(albedo_map,VaryingTexCoord.rg)*VaryingColor).a;
	float f_metalness=Texel(metal_map,VaryingTexCoord.rg).r*metalness;
	float f_roughness=Texel(rough_map,VaryingTexCoord.rg).r*roughness;
	float f_occlusion=Texel(occlusion_map,VaryingTexCoord.rg).r;
	
	vec3 N = Texel(normal_map,VaryingTexCoord.rg).xyz;
	N = N*2.0-1.0;
	N = normalize(TBN*N);
	
	vec3 V = normalize(view_position-f_position);
	
	vec3 R = reflect(-V,N);
	
	vec3 F0 = vec3(0.04);
	F0 = mix(F0,f_albedo,f_metalness);
	
	vec3 Lo=vec3(0.0);
	for (int i=0; i<MAX_LIGHTS; i++) {
		vec3 light_position=point_light_positions[i];
		vec3 light_color=point_light_colors[i];
		
		vec3 L = normalize(light_position-f_position);
		vec3 H = normalize(V+L);
		
		float distance    = length(light_position-f_position);
		float attenuation = 1.0/(distance*distance);
		vec3 radiance     = light_color*attenuation; 
		
		float NDF = DistributionGGX(N,H,f_roughness);
		float G   = GeometrySmith(N,V,L,f_roughness);
		vec3 F    = fresnelSchlick(max(dot(H,V),0.0),F0);
		//vec3 F = fresnelSchlickRoughness(max(dot(H,V),0.0),F0,f_roughness);
		
		vec3 numerator    = NDF*G*F;
		float denominator = 4.0*max(dot(N,V),0.0)*max(dot(N,L),0.0);
		vec3 specular     = numerator/max(denominator,0.001);
		
		vec3 kS = F;
		vec3 kD = vec3(1.0)-kS;
		kD *= 1.0-f_metalness;
		
		float NdotL = max(dot(N,L),0.0);
		
		Lo += (kD*f_albedo/PI+specular)*radiance*NdotL;
	}
	
	//vec3 kS = fresnelSchlickRoughness(max(dot(N,V),0.0),F0,f_roughness);
	vec3 kS = fresnelSchlick(max(dot(N,V),0.0),F0);
    vec3 kD = 1.0-kS;
	kD *= 1.0-f_metalness;
	
	vec3 irradiance = Texel(irradiance_map,N).rgb;
	vec3 diffuse = irradiance*f_albedo;
	vec3 ambient = (kD*diffuse)*f_occlusion;

	vec3 color = ambient+Lo;
	color = color/(color+vec3(1.0));
	color = pow(color,vec3(1.0/2.2));
	
	love_Canvases[0]=vec4(color,opacity);
}