return function(luma,fage)
local eztask = luma:import "eztask"
local lmath  = luma:import "lmath"
local class  = luma:import "class"

-------------------------------------------------------------------------------

local material=fage.class.object:extend()

function material:__tostring()
	return "material"
end

material.callbacks={}

-------------------------------------------------------------------------------

function material:new()
	material.super.new(self)
	
	self.material_id = eztask.property.new(1)
	
	self.albedo    = eztask.property.new(lmath.color3.new(1,1,1))
	self.opacity   = eztask.property.new(1)
	self.emission  = eztask.property.new(lmath.color3.new(0,0,0))
	self.bloom     = eztask.property.new(0)
	self.metalness = eztask.property.new(0)
	self.roughness = eztask.property.new(1)
	
	self.albedo_map    = eztask.property.new()
	self.emission_map  = eztask.property.new()
	self.bloom_map     = eztask.property.new()
	self.metal_map     = eztask.property.new()
	self.rough_map     = eztask.property.new()
	self.normal_map    = eztask.property.new()
	self.occlusion_map = eztask.property.new()
end

function material:delete()
	material.super.delete(self)
end

-------------------------------------------------------------------------------



-------------------------------------------------------------------------------

return material
end