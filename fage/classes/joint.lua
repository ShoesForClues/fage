return function(luma,fage)
local eztask = luma:import "eztask"
local lmath  = luma:import "lmath"
local class  = luma:import "class"

local unpack = unpack or table.unpack

-------------------------------------------------------------------------------

local joint=fage.class.object:extend()

function joint:__tostring()
	return "joint"
end

joint.callbacks={}

-------------------------------------------------------------------------------

function joint:new(joint_list,joint_id)
	joint.super.new(self)
	
	self.joint_id           = eztask.property.new(1)
	self.local_transform    = eztask.property.new(lmath.matrix4.new())
	self.inverse_transform  = eztask.property.new(lmath.matrix4.new())
	self.model_transform    = eztask.property.new(lmath.matrix4.new())
	self.animated_transform = eztask.property.new(lmath.matrix4.new())
	
	self.parent:            attach(joint.callbacks.parent,self)
	self.local_transform:   attach(joint.callbacks.local_transform,self)
	self.inverse_transform: attach(joint.callbacks.inverse_transform,self)
	
	if joint_list then
		local joint_data=joint_list[joint_id or 1]
		
		self.name._value=joint_data.name
		self.joint_id._value=joint_data.id
		self.local_transform._value=lmath.matrix4.new(
			unpack(joint_data.local_transform)
		)
		self.inverse_transform._value=lmath.matrix4.new(
			unpack(joint_data.inverse_bind_transform)
		)
		
		for _,child_id in ipairs(joint_data.children_ids) do
			joint(joint_list,child_id)
			:set("parent",self)
		end
		
		self:update_animated_transform()
	end
end

function joint:delete()
	joint.super.delete(self)
end

function joint:update_animated_transform()
	local parent=self.parent.value
	
	if parent and parent:is(joint) then
		self.model_transform.value
		:set(parent.model_transform.value:unpack())
		:multiply(self.local_transform.value)
	else
		self.model_transform.value
		:set(self.local_transform.value:unpack())
	end
	
	self.animated_transform.value
	:set(self.model_transform.value:unpack())
	:multiply(self.inverse_transform.value)
	
	local child_joints=self:get_children_by_class(joint)
	
	if child_joints then
		for _,child_joint in pairs(child_joints) do
			child_joint:update_animated_transform()
		end
	end
end

-------------------------------------------------------------------------------

joint.callbacks.parent=function(joint_)
	joint_:update_animated_transform()
end

joint.callbacks.local_transform=function(joint_)
	joint_:update_animated_transform()
end

joint.callbacks.inverse_transform=function(joint_)
	joint_:update_animated_transform()
end

-------------------------------------------------------------------------------

return joint
end