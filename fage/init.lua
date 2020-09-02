--[[
Fun Arcade Game Engine

MIT License

Copyright (c) 2020 Shoelee

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

return {__llib__=function(luma,src)
local eztask  = luma:import "eztask"
local class   = luma:import "class"
local lmath   = luma:import "lmath"
local enum    = luma:import "enum"
local slaxml  = luma:import "slaxml"
local slaxdom = luma:import "slaxdom"
local mimp    = luma:import "mimp"
local fps     = luma:import "fps"

-------------------------------------------------------------------------------

local fage={
	version = "0.0.4",
	enum    = {},
	class   = {},
	backend = nil
}

-------------------------------------------------------------------------------

--Load modules
fage.mesh      = luma.require(src.."/modules/mesh")      (luma,fage)
fage.texture   = luma.require(src.."/modules/texture")   (luma,fage)
fage.cubemap   = luma.require(src.."/modules/cubemap")   (luma,fage)
fage.animation = luma.require(src.."/modules/animation") (luma,fage)
fage.physics   = luma.require(src.."/modules/physics")   (luma,fage)

--Load classes
fage.class.object        = luma.require(src.."/classes/object")        (luma,fage)
fage.class.render_object = luma.require(src.."/classes/render_object") (luma,fage)
fage.class.scene         = luma.require(src.."/classes/scene")         (luma,fage)
fage.class.camera        = luma.require(src.."/classes/camera")        (luma,fage)
fage.class.part          = luma.require(src.."/classes/part")          (luma,fage)
fage.class.mesh          = luma.require(src.."/classes/mesh")          (luma,fage)
fage.class.material      = luma.require(src.."/classes/material")      (luma,fage)
fage.class.joint         = luma.require(src.."/classes/joint")         (luma,fage)
fage.class.point_light   = luma.require(src.."/classes/point_light")   (luma,fage)

-------------------------------------------------------------------------------

--Wrap classes
for class_name,class_ in pairs(fage.class) do
	for atr_name,atr in pairs(class_) do
		if type(atr)=="function" and atr_name:sub(1,2)~="__" then
			class_[atr_name]=function(instance,...)
				if 
					fage.backend
					and fage.backend.class[class_name]
					and fage.backend.class[class_name][atr_name]
				then
					return
						atr(instance,...),
						fage.backend.class[class_name][atr_name](instance,...)
				else
					return atr(instance,...)
				end
			end
		end
	end
end

-------------------------------------------------------------------------------

function fage.new(class_name,...)
	if not fage.class[class_name] then
		error(("Invalid class %s"):format(class_name))
	end
	return fage.class[class_name](...)
end

function fage:init(source)
	fage.backend=luma.require(source)(luma,source,fage)
end

-------------------------------------------------------------------------------

return fage
end}