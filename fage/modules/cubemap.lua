return function(luma,fage)
local cubemap={loaded={}}

-------------------------------------------------------------------------------

function cubemap.load(source)
	assert(fage.backend,"Backend not initialized.")
	assert(fage.backend.cubemap,"Cubemap is not supported.")
	
	cubemap.loaded[source]=(
		cubemap.loaded[source]
		or fage.backend.cubemap.load(source)
	)
	
	pcall(collectgarbage)
	
	return source
end

function cubemap.delete(source)
	assert(fage.backend,"Backend not initialized.")
	assert(
		cubemap.loaded[source],
		("Invalid cubemap %s"):format(source)
	)
	
	fage.backend.cubemap.delete(cubemap.loaded[source])
	
	cubemap.loaded[source]=nil
	
	pcall(collectgarbage)
end

-------------------------------------------------------------------------------

return cubemap
end