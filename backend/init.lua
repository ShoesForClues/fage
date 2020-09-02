--FAGE implementation for Love2D

return function(luma,src,fage)
local backend={class={},shader={}}

-------------------------------------------------------------------------------

--Init modules
backend.mesh      = require(src.."/modules/mesh")      (luma,fage,backend)
backend.texture   = require(src.."/modules/texture")   (luma,fage,backend)
backend.animation = require(src.."/modules/animation") (luma,fage,backend)
backend.cubemap   = require(src.."/modules/cubemap")   (luma,fage,backend)

--Init classes
backend.class.scene  = require(src.."/classes/scene")  (luma,fage,backend)
backend.class.camera = require(src.."/classes/camera") (luma,fage,backend)
backend.class.mesh   = require(src.."/classes/mesh")   (luma,fage,backend)

--Init shaders
backend.shader.skybox=love.graphics.newShader(
	src.."/shaders/skybox.glsl"
)
backend.shader.forward=love.graphics.newShader(
	src.."/shaders/forward_vertex.glsl",
	src.."/shaders/forward_fragment.glsl"
)
backend.shader.ssao=love.graphics.newShader(
	src.."/shaders/ssao.glsl"
)
backend.shader.ssao_blur=love.graphics.newShader(
	src.."/shaders/ssao_blur.glsl"
)
backend.shader.depth=love.graphics.newShader(
	src.."/shaders/depth.glsl"
)
backend.shader.hdr_to_cube=love.graphics.newShader(
	src.."/shaders/hdr_to_cube.glsl"
)
backend.shader.convolute=love.graphics.newShader(
	src.."/shaders/convolute.glsl"
)

--Create textures
local blank_texture=love.graphics.newCanvas(1,1)
love.graphics.push("all")
love.graphics.setCanvas(blank_texture)
love.graphics.clear(1,1,1,1)
love.graphics.pop()
fage.texture.loaded.blank=blank_texture

local blank_normal=love.graphics.newCanvas(1,1)
love.graphics.push("all")
love.graphics.setCanvas(blank_normal)
love.graphics.clear(0.5,0.5,1,1)
love.graphics.pop()
fage.texture.loaded.blank_normal=blank_normal

--Load meshes
fage.mesh.loaded.cube=backend.mesh.load(
	src.."/meshes/skybox.obj",
	fage.mesh.enum.file_format.wavefront
)

-------------------------------------------------------------------------------

return backend
end