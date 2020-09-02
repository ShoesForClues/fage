return function(luma,fage,backend)
local mimp = luma:import "mimp"

-------------------------------------------------------------------------------

local mesh={formats={}}

-------------------------------------------------------------------------------

mesh.formats.static={
	{"VertexPosition","float",3},
	{"VertexNormal","float",3},
	{"VertexTexCoord","float",2},
	{"MaterialId","float",1}
}

mesh.formats.rig={
	{"VertexPosition","float",3},
	{"VertexNormal","float",3},
	{"VertexTexCoord","float",2}, 
	{"MaterialId","float",1},
	{"JointIds","float",4},
	{"JointWeights","float",4},
	{"ATangent","float",3},
	{"ABitangent","float",3}
}

-------------------------------------------------------------------------------

function get_tangents(e1x,e1y,e1z,e2x,e2y,e2z,duv1x,duv1y,duv2x,duv2y)
	local f=1/(duv1x*duv2y-duv2x*duv1y)
	return
		f*(duv2y*e1x-duv1y*e2x),
		f*(duv2y*e1y-duv1y*e2y),
		f*(duv2y*e1z-duv1y*e2z),
		f*(-duv2x*e1x+duv1x*e2x),
		f*(-duv2x*e1y+duv1x*e2y),
		f*(-duv2x*e1z+duv1x*e2z)
end

-------------------------------------------------------------------------------

function mesh.load(source,file_format)
	local data=love.filesystem.read(source)
	local mesh_format=mesh.formats.rig
	local mesh_data={}
	local mesh_info
	
	if file_format==fage.mesh.enum.file_format.wavefront then
		mesh_info=mimp.load_model(data,"wavefront")
	elseif file_format==fage.mesh.enum.file_format.collada then
		mesh_info=mimp.load_model(data,"collada")
		mesh_format=mesh.formats.rig
	end
	
	if #mesh_info.joints>0 then
		mesh_format=mesh.formats.rig
	end
	
	for _,face in ipairs(mesh_info.faces) do
		local v1=mesh_info.vertices[face[1][1]]
		local v2=mesh_info.vertices[face[2][1]]
		local v3=mesh_info.vertices[face[3][1]]
		
		local uv1=mesh_info.uvs[face[1][3]]
		local uv2=mesh_info.uvs[face[2][3]]
		local uv3=mesh_info.uvs[face[3][3]]
		
		local e1x=v2[1]-v1[1]
		local e1y=v2[2]-v1[2]
		local e1z=v2[3]-v1[3]
		
		local e2x=v3[1]-v1[1]
		local e2y=v3[2]-v1[2]
		local e2z=v3[3]-v1[3]
		
		local duv1x=uv2[1]-uv1[1]
		local duv1y=uv2[2]-uv1[2]
		
		local duv2x=uv3[1]-uv1[1]
		local duv2y=uv3[2]-uv1[2]
		
		local atx,aty,atz,abtx,abty,abtz=get_tangents(
			e1x,e1y,e1z,
			e2x,e2y,e2z,
			duv1x,duv1y,
			duv2x,duv2y
		)
		
		for f=1,#face do
			local vertex={}
			
			local v   = mesh_info.vertices[face[f][1]]
			local vn  = mesh_info.normals[face[f][2]]
			local uv  = mesh_info.uvs[face[f][3]]
			local tm  = face[f][4]
			local jid = mesh_info.joint_ids[face[f][1]]
			local jw  = mesh_info.joint_weights[face[f][1]]
			
			for i=1,mesh_format[1][3] do
				vertex[#vertex+1]=v and v[i] or 0
			end
			for i=1,mesh_format[2][3] do
				vertex[#vertex+1]=vn and vn[i] or 0
			end
			for i=1,mesh_format[3][3] do
				vertex[#vertex+1]=uv and uv[i] or 0
			end
			vertex[#vertex+1]=(tm or 1)-1
			if mesh_format==mesh.formats.rig then
				for i=1,mesh_format[5][3] do
					vertex[#vertex+1]=jid and jid[i] or 0
				end
				for i=1,mesh_format[6][3] do
					vertex[#vertex+1]=jw and jw[i] or 0
				end
			end
			
			vertex[#vertex+1]=atx
			vertex[#vertex+1]=aty
			vertex[#vertex+1]=atz
			vertex[#vertex+1]=abtx
			vertex[#vertex+1]=abty
			vertex[#vertex+1]=abtz
			
			mesh_data[#mesh_data+1]=vertex
		end
	end
	
	return {
		drawable=love.graphics.newMesh(
			mesh_format,mesh_data,
			"triangles","static"
		),
		materials=mesh_info.materials,
		joints=mesh_info.joints
	}
end

function mesh.delete(source)
	source.mesh_object:release()
end

-------------------------------------------------------------------------------

return mesh
end