#pragma language glsl3

const int MAX_JOINTS=200;
const int MAX_WEIGHTS=4;

varying vec3 f_normal;
varying vec3 f_position;
flat varying float f_material;

uniform highp mat4 projection;
uniform highp mat4 view;
uniform highp mat4 model;

uniform highp mat4 joint_transforms[MAX_JOINTS];

#ifdef VERTEX
attribute vec3 VertexNormal;
attribute float MaterialId;
attribute vec4 JointIds;
attribute vec4 JointWeights;

vec4 position(highp mat4 transform_projection,highp vec4 vertex_position) {
	vec4 total_local_pos=vec4(0.0);
	vec4 total_normal=vec4(0.0);
	
	if (length(JointWeights)>0.0) {
		for (int i=0; i<MAX_WEIGHTS; i++) {
			highp mat4 joint_transform=joint_transforms[int(JointIds[i])];
			float joint_weight=JointWeights[i];
			
			vec4 local_position=joint_transform*vertex_position;
			total_local_pos+=local_position*joint_weight;
			
			vec4 world_normal=joint_transform*vec4(VertexNormal,0.0);
			total_normal+=world_normal*joint_weight;
		}
	} else {
		total_local_pos=vertex_position;
		total_normal=vec4(VertexNormal,0.0);
	}
	
	f_position = (view*model*total_local_pos).xyz;
	f_normal   = (view*model*total_normal).xyz;
	f_material = MaterialId;
	
	return projection*view*model*total_local_pos;
}
#endif