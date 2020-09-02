return function(luma,fage)
local eztask = luma:import "eztask"
local lmath  = luma:import "lmath"
local class  = luma:import "class"

-------------------------------------------------------------------------------

local scene=fage.class.object:extend()

function scene:__tostring()
	return "scene"
end

scene.callbacks={}

-------------------------------------------------------------------------------

function scene:new()
	scene.super.new(self)
	
	self.batch_render = {}
	self.lights       = {}
	
	self.fog_color    = eztask.property.new(lmath.color3.new(1,1,1))
	self.fog_density  = eztask.property.new(0)
	self.fog_gradient = eztask.property.new(10000)
	
	self.sky_map = eztask.property.new()
	
	self.descendant_added:   attach(scene.callbacks.descendant_added,self)
	self.descendant_removed: attach(scene.callbacks.descendant_removed,self)
end

function scene:delete()
	scene.super.delete(self)
end

-------------------------------------------------------------------------------

scene.callbacks.descendant_added=function(scene_,object_)
	if object_:is(fage.class.render_object) then
		object_.scene.value=scene_
	elseif object_:is(fage.class.point_light) then
		scene_.lights[object_]=object_
	end
end

scene.callbacks.descendant_removed=function(scene_,object_)
	if object_:is(fage.class.render_object) then
		object_.scene.value=nil
	elseif object_:is(fage.class.point_light) then
		scene_.lights[object_]=nil
	end
end

-------------------------------------------------------------------------------

return scene
end