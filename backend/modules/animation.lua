return function(luma,fage,backend)
local mimp = luma:import "mimp"

-------------------------------------------------------------------------------

local animation={formats={}}

-------------------------------------------------------------------------------



-------------------------------------------------------------------------------

function animation.load(source,file_format)
	local data=love.filesystem.read(source)
	
	if file_format==fage.mesh.enum.file_format.collada then
		return mimp.load_animation(data,"collada")
	end
end

function animation.delete(source)
	
end

-------------------------------------------------------------------------------

return animation
end