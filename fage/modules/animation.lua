return function(luma,fage)
local enum = luma:import "enum"

-------------------------------------------------------------------------------

local animation={
	loaded = {},
	enum   = {}
}

-------------------------------------------------------------------------------

animation.enum.file_format=enum {
	"wavefront",
	"collada"
}

-------------------------------------------------------------------------------

function animation.load(source,file_format)
	assert(fage.backend,"Backend not initialized.")
	assert(fage.backend.animation,"Animation is not supported.")
	
	if not file_format and type(source)=="string" then
		local extension=source:match("^.+(%..+)$"):lower()
		if extension==".obj" then
			file_format=animation.enum.file_format.wavefront
		elseif extension==".dae" then
			file_format=animation.enum.file_format.collada
		end
	end
	
	assert(file_format,"File format not specified or invalid.")
	
	animation.loaded[source]=(
		animation.loaded[source]
		or fage.backend.animation.load(source,file_format)
	)
	
	pcall(collectgarbage)
	
	return source
end

function animation.delete(id)
	assert(fage.backend,"Backend not initialized.")
	assert(
		animation.loaded[id],
		("Invalid animation %s"):format(id)
	)
	
	fage.backend.animation.delete(animation.loaded[id])
	
	animation.loaded[id]=nil
	
	pcall(collectgarbage)
end

-------------------------------------------------------------------------------

return animation
end