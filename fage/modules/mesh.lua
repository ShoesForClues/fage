return function(luma,fage)
local enum = luma:import "enum"

-------------------------------------------------------------------------------

local mesh={
	loaded = {},
	enum   = {}
}

-------------------------------------------------------------------------------

mesh.enum.file_format=enum {
	"wavefront",
	"collada"
}

-------------------------------------------------------------------------------

function mesh.load(source,file_format)
	assert(fage.backend,"Backend not initialized.")
	assert(fage.backend.mesh,"Mesh is not supported.")
	
	if not file_format and type(source)=="string" then
		local extension=source:match("^.+(%..+)$")
		if extension==".obj" then
			file_format=mesh.enum.file_format.wavefront
		elseif extension==".dae" then
			file_format=mesh.enum.file_format.collada
		end
	end
	
	assert(file_format,"File format not specified or invalid.")
	
	mesh.loaded[source]=(
		mesh.loaded[source]
		or fage.backend.mesh.load(source,file_format)
	)
	
	pcall(collectgarbage)
	
	return source
end

function mesh.delete(id)
	assert(fage.backend,"Backend not initialized.")
	assert(
		mesh.loaded[id],
		("Invalid mesh %s"):format(id)
	)
	
	fage.backend.mesh.delete(mesh.loaded[id])
	
	mesh.loaded[id]=nil
	
	pcall(collectgarbage)
end

-------------------------------------------------------------------------------

return mesh
end