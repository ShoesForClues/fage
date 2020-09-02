return function(luma,fage)
local eztask = luma:import "eztask"
local lmath  = luma:import "lmath"
local class  = luma:import "class"

-------------------------------------------------------------------------------

local camera=fage.class.object:extend()

function camera:__tostring()
	return "camera"
end

camera.callbacks={}

-------------------------------------------------------------------------------

function camera:new()
	camera.super.new(self)
	
	self.transform     = eztask.property.new(lmath.matrix4.new())
	self.projection    = eztask.property.new(lmath.matrix4.new())
	self.viewport_size = eztask.property.new(lmath.vector2.new())
	self.field_of_view = eztask.property.new(70)
	
	self.viewport_size: attach(camera.callbacks.viewport_size,self)
	self.field_of_view: attach(camera.callbacks.field_of_view,self)
end

function camera:delete()
	camera.super.delete(self)
end

function camera:draw()
end

function camera:update_projection()
	self.projection.value:set_perspective(
		self.field_of_view.value,
		self.viewport_size.value.x/self.viewport_size.value.y,
		0.5,1000
	)
end

-------------------------------------------------------------------------------

camera.callbacks.viewport_size=function(instance)
	instance:update_projection()
end

camera.callbacks.field_of_view=function(instance)
	instance:update_projection()
end

-------------------------------------------------------------------------------

return camera
end