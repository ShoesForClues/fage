return function(luma,fage)
local texture={loaded={}}

-------------------------------------------------------------------------------

function texture.load(source)
	assert(fage.backend,"Backend not initialized.")
	assert(fage.backend.texture,"Texture is not supported.")
	
	texture.loaded[source]=(
		texture.loaded[source]
		or fage.backend.texture.load(source)
	)
	
	pcall(collectgarbage)
	
	return source
end

function texture.delete(source)
	assert(fage.backend,"Backend not initialized.")
	assert(
		texture.loaded[source],
		("Invalid texture %s"):format(source)
	)
	
	fage.backend.texture.delete(texture.loaded[source])
	
	texture.loaded[source]=nil
	
	pcall(collectgarbage)
end

function texture.get_texture_size(source)
	assert(fage.backend,"Backend not initialized.")
	assert(
		texture.loaded[source],
		("Invalid texture %s"):format(source)
	)
	
	return fage.backend.texture.get_texture_size(
		texture.loaded[source]
	)
end

-------------------------------------------------------------------------------

return texture
end