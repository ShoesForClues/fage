return function(luma,fage)
local eztask = luma:import "eztask"
local lmath  = luma:import "lmath"
local class  = luma:import "class"

-------------------------------------------------------------------------------

local point_light=fage.class.object:extend()

function point_light:__tostring()
	return "point_light"
end

point_light.callbacks={}

-------------------------------------------------------------------------------

function point_light:new()
	point_light.super.new(self)
	
	self.transform  = eztask.property.new(lmath.matrix4.new())
	self.brightness = eztask.property.new(1)
	self.range      = eztask.property.new(10)
	self.angle      = eztask.propert.new(math.pi)
	self.color      = eztask.property.new(lmath.color3.new(1,1,1))
end

function point_light:delete()
	point_light.super.delete(self)
end

-------------------------------------------------------------------------------

return point_light
end