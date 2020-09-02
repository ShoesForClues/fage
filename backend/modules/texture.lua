return function(luma,fage,backend)
local texture={}

-------------------------------------------------------------------------------

function texture.load(source)
	return love.graphics.newImage(source)
end

function texture.delete(texture)
	texture:release()
end

function texture.get_texture_size(texture)
	return texture:getWidth(),texture:getHeight()
end

-------------------------------------------------------------------------------

return texture
end