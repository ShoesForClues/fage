#pragma language glsl3

uniform float radius;
uniform vec2 dir;

vec4 effect(vec4 color,sampler2D u_texture,vec2 texcoord,vec2 screencoord) {
	vec4 sum=vec4(0.0);
	
	vec2 tc=texcoord;
	
	float blur=radius/length(dir*love_ScreenSize.xy); 
	
	float hstep = dir.x;
	float vstep = dir.y;
	
	sum += Texel(u_texture,vec2(tc.x-4.0*blur*hstep,tc.y-4.0*blur*vstep))*0.0162162162;
	sum += Texel(u_texture,vec2(tc.x-3.0*blur*hstep,tc.y-3.0*blur*vstep))*0.0540540541;
	sum += Texel(u_texture,vec2(tc.x-2.0*blur*hstep,tc.y-2.0*blur*vstep))*0.1216216216;
	sum += Texel(u_texture,vec2(tc.x-1.0*blur*hstep,tc.y-1.0*blur*vstep))*0.1945945946;
	
	sum += Texel(u_texture,vec2(tc.x,tc.y))*0.2270270270;
	
	sum += Texel(u_texture,vec2(tc.x+1.0*blur*hstep,tc.y+1.0*blur*vstep))*0.1945945946;
	sum += Texel(u_texture,vec2(tc.x+2.0*blur*hstep,tc.y+2.0*blur*vstep))*0.1216216216;
	sum += Texel(u_texture,vec2(tc.x+3.0*blur*hstep,tc.y+3.0*blur*vstep))*0.0540540541;
	sum += Texel(u_texture,vec2(tc.x+4.0*blur*hstep,tc.y+4.0*blur*vstep))*0.0162162162;
	
	return color*vec4(sum.rgb,1.0);
}