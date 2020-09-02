return function(luma,fage,backend)
local lmath = luma:import "lmath"

-------------------------------------------------------------------------------

local mesh={}

-------------------------------------------------------------------------------

local temp_matrix4_1=lmath.matrix4.new()

-------------------------------------------------------------------------------

function mesh.draw(mesh_,camera_,shader)
	local parent_transform=mesh_.parent.value.transform.value
	
	local cx,cy,cz=camera_.transform.value:get_position()
	
	local transform=temp_matrix4_1
	:set(parent_transform:unpack())
	:scale(mesh_.scale.value:unpack())
	
	local albedo_map=fage.texture.loaded[mesh_.albedo_map.value]
	
	shader:send("model","row",transform)
	
	if albedo_map then
		shader:send("albedo_map",albedo_map)
	end
	
	love.graphics.setColor(
		mesh_.color.value.r,
		mesh_.color.value.g,
		mesh_.color.value.b,
		mesh_.opacity.value
	)
	
	love.graphics.setMeshCullMode("front")
	love.graphics.draw(fage.mesh.loaded[mesh_.mesh.value])
end

-------------------------------------------------------------------------------

return mesh
end