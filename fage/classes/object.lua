return function(luma,fage)
local eztask = luma:import "eztask"
local lmath  = luma:import "lmath"
local class  = luma:import "class"

local remove = table.remove
local insert = table.insert

-------------------------------------------------------------------------------

local object=class:extend()

function object:__tostring()
	return "object"
end

object.callbacks={}

-------------------------------------------------------------------------------

function object:new()
	self.children = {name={},class={}}
	
	self.parent = eztask.property.new()
	self.name   = eztask.property.new(tostring(self))
	
	self.child_added        = eztask.signal.new()
	self.child_removed      = eztask.signal.new()
	self.descendant_added   = eztask.signal.new()
	self.descendant_removed = eztask.signal.new()
	
	self.parent:             attach(object.callbacks.parent,self)
	self.name:               attach(object.callbacks.name,self)	
	self.child_added:        attach(object.callbacks.child_added,self)
	self.child_removed:      attach(object.callbacks.child_removed,self)
	self.descendant_added:   attach(object.callbacks.descendant_added,self)
	self.descendant_removed: attach(object.callbacks.descendant_removed,self)
end

function object:delete()
	self.parent.value=nil
	for _,objects in pairs(self.children.class) do
		for _,child in pairs(objects) do
			child:delete()
		end
	end
	for atr_name,atr in pairs(self) do
		local mt=getmetatable(atr)
		if
			mt==eztask.callback
			or mt==eztask.signal
			or mt==eztask.property
		then
			atr:detach()
		end
	end
end

function object:get_children()
	local children={}
	for _,objects in pairs(self.children.class) do
		for _,child in pairs(objects) do
			children[child]=child
		end
	end
	return children
end

function object:get_children_by_name(name)
	return self.children.name[name]
end

function object:get_children_by_class(class_)
	return self.children.class[class_]
end

function object:get_children_by_class_name(class_name)
	return self.children.class[fage.class[class_name]]
end

function object:get_child_by_name(name)
	if self.children.name[name] then
		local child=next(self.children.name[name])
		return child
	end
end

function object:get_child_by_class(class_)
	if self.children.class[class_] then
		local child=next(self.children.class[class_])
		return child
	end
end

function object:get_child_by_class_name(class_name)
	local class_=fage.class[class_name]
	if self.children.class[class_] then
		local child=next(self.children.class[class_])
		return child
	end
end

function object:get_descendant_by_name(name)
	if self.name.value==name then
		return self
	end
	
	local descendant=self:get_child_by_name(name)
	
	if not descendant then
		for _,objects in pairs(self.children.name) do
			for _,child in pairs(objects) do
				descendant=child:get_descendant_by_name(name)
				if descendant then
					break
				end
			end
			if descendant then
				break
			end
		end
	end
	
	return descendant
end

function object:set(property_name,value)
	if self[property_name] then
		self[property_name].value=value
		return self
	else
		error(("%s is not a valid property!"):format(property_name))
	end
end

-------------------------------------------------------------------------------

object.callbacks.parent=function(instance,new_parent,old_parent)
	local name=instance.name.value
	local class_=getmetatable(instance)
	if old_parent then
		if old_parent.children.name[name] then
			old_parent.children.name[name][instance]=nil
			if not next(old_parent.children.name[name]) then
				old_parent.children.name[name]=nil
			end
		end
		if old_parent.children.class[class_] then
			old_parent.children.class[class_][instance]=nil
			if not next(old_parent.children.class[class_]) then
				old_parent.children.class[class_]=nil
			end
		end
		old_parent.child_removed(instance)
	end
	if new_parent then
		local objects_name=new_parent.children.name[name] or {}
		local objects_class=new_parent.children.class[class_] or {}
		objects_name[instance]=instance
		objects_class[instance]=instance
		new_parent.children.name[name]=objects_name
		new_parent.children.class[class_]=objects_class
		new_parent.child_added(instance)
	end
end

object.callbacks.name=function(instance,new_name,old_name)
	local parent=instance.parent.value
	new_name=tostring(new_name or instance)
	instance.name._value=new_name
	if not parent then
		return
	end
	if old_name and parent.children.name[old_name] then
		parent.children.name[old_name][instance]=nil
		if not next(parent.children.name[old_name]) then
			parent.children.name[old_name]=nil
		end
	end
	if new_name then
		local objects=parent.children.name[new_name] or {}
		objects[instance]=instance
		parent.children.name[new_name]=objects
	end
end

object.callbacks.child_added=function(instance,child)
	instance.descendant_added(child)
end

object.callbacks.child_removed=function(instance,child)
	instance.descendant_removed(child)
end

object.callbacks.descendant_added=function(instance,descendant)
	local parent=instance.parent.value
	if parent then
		parent.descendant_added(descendant)
	end
end

object.callbacks.descendant_removed=function(instance,descendant)
	local parent=instance.parent.value
	if parent then
		parent.descendant_removed(descendant)
	end
end

-------------------------------------------------------------------------------

return object
end