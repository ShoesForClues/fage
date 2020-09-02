return function(luma,fage,backend)
local lmath = luma:import "lmath"

local unpack = unpack or table.unpack

local max = math.max

-------------------------------------------------------------------------------

local temp_matrix4_1=lmath.matrix4.new()
local temp_matrix4_2=lmath.matrix4.new()
local temp_matrix4_identity=lmath.matrix4.new()

local temp_vector3_1=lmath.vector3.new()
local temp_vector3_2=lmath.vector3.new()
local temp_vector3_3=lmath.vector3.new()
local temp_vector3_4=lmath.vector3.new()

local material_list={}
local joint_list={}

local nearest_lights={}
local light_positions={
	{0,0,0},
	{0,0,0},
	{0,0,0},
	{0,0,0}
}
local light_colors={
	{0,0,0},
	{0,0,0},
	{0,0,0},
	{0,0,0}
}

-------------------------------------------------------------------------------

function populate_joint_list(joint,list)
	list[joint.joint_id.value]=joint.animated_transform.value
	local child_joints=joint:get_children_by_class(fage.class.joint)
	if child_joints then
		for _,child_joint in pairs(child_joints) do
			populate_joint_list(child_joint,list)
		end
	end
end

-------------------------------------------------------------------------------

local mesh={}

-------------------------------------------------------------------------------

function mesh.draw(mesh_,scene,shader)
	local transform=temp_matrix4_1:set()
	local current_transform=temp_matrix4_2:set()
	
	local current_parent=mesh_.parent.value
	
	local mesh_object=fage.mesh.loaded[mesh_.mesh.value]
	
	local blank_texture=fage.texture.loaded.blank
	local blank_normal=fage.texture.loaded.blank_normal
	
	while current_parent and current_parent.transform do
		current_transform:set(transform:unpack())
		
		transform:set(current_parent.transform.value:unpack())
		:multiply(current_transform)
		
		current_parent=current_parent.parent.value
	end
	
	transform:scale(mesh_.scale.value:unpack())
	
	love.graphics.setMeshCullMode("front")
	
	shader:send("model","row",transform)
	
	local materials=mesh_:get_children_by_class(fage.class.material)
	local joints=mesh_:get_children_by_class(fage.class.joint)
	
	local material_count=max(1,#mesh_object.materials)
	local joint_count=max(1,#mesh_object.joints)
	
	for id=1,material_count do
		material_list[id]=nil
	end
	
	for id=1,joint_count do
		joint_list[id]=temp_matrix4_identity
	end
	
	if materials then
		for _,material in pairs(materials) do
			local id=lmath.clamp(material.material_id.value,1,16)
			material_list[id]=material
		end
	end
	
	if joints then
		for _,joint in pairs(joints) do
			populate_joint_list(joint,joint_list)
		end
	end
	
	if shader:hasUniform("joint_transforms") then
		shader:send("joint_transforms","row",unpack(joint_list))
	end
	
	if shader:hasUniform("point_light_positions") then
		for i=1,4 do
			nearest_lights[i]=nil
			light_positions[i][1],
			light_positions[i][2],
			light_positions[i][3]=0,0,0
			light_colors[i][1],
			light_colors[i][2],
			light_colors[i][3]=0,0,0
		end
		
		for i=1,4 do
			local nearest_light
			for _,light in pairs(scene.lights) do
				if light.enabled.value then
					local appended=false
					for _,appended_light in ipairs(nearest_lights) do
						if appended_light==light then
							appended=true
							break
						end
					end
					if not appended then
						if not nearest_light then
							nearest_light=light
						else
							local influence_1=temp_vector3_1
							:set(light.transform.value:get_position())
							:subtract(temp_vector3_2:set(transform:get_position()))
							:get_magnitude()/light.intensity.value
							
							local influence_2=temp_vector3_3
							:set(nearest_light.transform.value:get_position())
							:subtract(temp_vector3_4:set(transform:get_position()))
							:get_magnitude()/nearest_light.intensity.value
							
							if influence_1<influence_2 then
								nearest_light=light
							end
						end
					end
				end
			end
			
			nearest_lights[i]=nearest_light
			
			if nearest_light then
				local r,g,b=nearest_light.color.value:unpack()
				local intensity=nearest_light.intensity.value
				light_positions[i][1],
				light_positions[i][2],
				light_positions[i][3]=nearest_light.transform.value:get_position()
				light_colors[i][1]=r*intensity
				light_colors[i][2]=g*intensity
				light_colors[i][3]=b*intensity
			end
		end
		
		shader:send("point_light_positions",unpack(light_positions))
		shader:send("point_light_colors",unpack(light_colors))
	end
	
	for id=1,material_count do
		local r,g,b,a=1,1,1,1
		
		local material=material_list[id]
		
		local metalness=0
		local roughness=1
		local albedo_map
		local metal_map
		local rough_map
		local normal_map
		local occlusion_map
		
		if material then
			metalness=material.metalness.value
			roughness=material.roughness.value
			
			albedo_map=fage.texture.loaded[material.albedo_map.value]
			metal_map=fage.texture.loaded[material.metal_map.value]
			rough_map=fage.texture.loaded[material.rough_map.value]
			normal_map=fage.texture.loaded[material.normal_map.value]
			occlusion_map=fage.texture.loaded[material.occlusion_map.value]
			
			r=material.albedo.value.r
			g=material.albedo.value.g
			b=material.albedo.value.b
			a=material.opacity.value
		end
		
		if shader:hasUniform("albedo_map") then
			shader:send("albedo_map",albedo_map or blank_texture)
		end
		if shader:hasUniform("metal_map") then
			shader:send("metal_map",metal_map or blank_texture)
		end
		if shader:hasUniform("rough_map") then
			shader:send("rough_map",rough_map or blank_texture)
		end
		if shader:hasUniform("normal_map") then
			shader:send("normal_map",normal_map or blank_normal)
		end
		if shader:hasUniform("occlusion_map") then
			shader:send("occlusion_map",occlusion_map or blank_texture)
		end
		if shader:hasUniform("current_material") then
			shader:send("current_material",id-1)
		end
		if shader:hasUniform("metalness") then
			shader:send("metalness",metalness)
		end
		if shader:hasUniform("roughness") then
			shader:send("roughness",roughness)
		end
		
		love.graphics.setColor(r,g,b,a)
		love.graphics.draw(mesh_object.drawable)
	end
end

-------------------------------------------------------------------------------

return mesh
end