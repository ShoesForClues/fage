return function(luma,fage)
local eztask = luma:import "eztask"
local lmath  = luma:import "lmath"
local class  = luma:import "class"

-------------------------------------------------------------------------------

local part=fage.class.object:extend()

function part:__tostring()
	return "part"
end

part.callbacks={}

-------------------------------------------------------------------------------

function part:new()
	part.super.new(self)
	
	self.transform = eztask.property.new(lmath.matrix4.new())
	self.size      = eztask.property.new(lmath.vector3.new(1,1,1))
	self.anchored  = eztask.property.new(true)
	self.collision = eztask.property.new(false)
end

function part:delete()
	part.super.delete(self)
end

-------------------------------------------------------------------------------



-------------------------------------------------------------------------------

return part
end