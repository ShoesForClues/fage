return function(luma,fage)
local eztask = luma:import "eztask"
local lmath  = luma:import "lmath"
local class  = luma:import "class"

-------------------------------------------------------------------------------

local render_object=fage.class.object:extend()

function render_object:__tostring()
	return "render_object"
end

render_object.callbacks={}

-------------------------------------------------------------------------------

function render_object:new()
	render_object.super.new(self)
	
	self.batch_id = eztask.property.new()
	self.scene    = eztask.property.new()
	
	self.batch_id: attach(render_object.callbacks.batch_id,self)
	self.scene:    attach(render_object.callbacks.scene,self)
end

function render_object:delete()
	render_object.super.delete(self)
end

-------------------------------------------------------------------------------

render_object.callbacks.batch_id=function(instance,new_id,old_id)
	local scene=instance.scene.value
	
	if not scene then	
		return
	end
	
	if old_id then
		scene.batch_render[old_id][instance]=nil
		if not next(scene.batch_render[old_id]) then
			scene.batch_render[old_id]=nil
		end
	end
	
	if new_id then
		local batch=scene.batch_render[new_id] or {}
		batch[instance]=instance
		scene.batch_render[new_id]=batch
	end
end

render_object.callbacks.scene=function(instance,new_scene,old_scene)
	local batch_id=instance.batch_id.value
	
	if not batch_id then
		return
	end
	
	if old_scene then
		old_scene.batch_render[batch_id][instance]=nil
		if not next(old_scene.batch_render[batch_id]) then
			old_scene.batch_render[batch_id]=nil
		end
	end
	
	if new_scene then
		local batch=new_scene.batch_render[batch_id] or {}
		batch[instance]=instance
		new_scene.batch_render[batch_id]=batch
	end
end

-------------------------------------------------------------------------------

return render_object
end