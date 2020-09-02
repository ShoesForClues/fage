return function(luma,fage)
local eztask = luma:import "eztask"
local lmath  = luma:import "lmath"
local class  = luma:import "class"

-------------------------------------------------------------------------------

local mesh=fage.class.render_object:extend()

function mesh:__tostring()
	return "mesh"
end

mesh.callbacks={}

-------------------------------------------------------------------------------

function mesh:new()
	mesh.super.new(self)
	
	self.mesh    = eztask.property.new()
	self.scale   = eztask.property.new(lmath.vector3.new(1,1,1))
	
	self.mesh: attach(mesh.callbacks.mesh,self)
end

function mesh:delete()
	mesh.super.delete(self)
end

function mesh:draw() end

function mesh:update_batch_id()
	self.batch_id.value=self.mesh.value
end

-------------------------------------------------------------------------------

mesh.callbacks.mesh=function(instance,mesh_)
	instance:update_batch_id()
end

-------------------------------------------------------------------------------

return mesh
end