return function(luma,fage,backend)
local lmath = luma:import "lmath"

local random = math.random
local ceil   = math.ceil
local sqrt   = math.sqrt

-------------------------------------------------------------------------------

local camera={buffers={}}

-------------------------------------------------------------------------------

local temp_matrix4_1=lmath.matrix4.new()

local temp_vector3_1={}

local temp_vector2_1={}

local skybox_view=lmath.matrix4.new()

local reflection_cubemap=love.graphics.newCubeImage("assets/textures/skybox/63PbS.jpg")

-------------------------------------------------------------------------------

--Generate kernel samples to use for SSAO
local ssao_kernel_samples={}
for i=1,64 do
	local sample={random()*2-1,random()*2-1,random()}
	local m=sqrt(sample[1]^2+sample[2]^2+sample[3]^2)
	local d=random()*lmath.lerp(0.1,1,(i/64)^2)
	sample[1]=(sample[1]/m)*d
	sample[2]=(sample[2]/m)*d
	sample[3]=(sample[3]/m)*d
	ssao_kernel_samples[i]=sample
end

--Generate noise texture to use in conjunction for SSAO
local ssao_noise_texture=love.graphics.newCanvas(
	4,4,
	{format="rgba8"}
)
ssao_noise_texture:setWrap("repeat","repeat")
love.graphics.push("all")
love.graphics.setCanvas(ssao_noise_texture)
for i=0,15 do
	love.graphics.setColor(random()*2-1,random()*2-1,0,1)
	love.graphics.points(ceil(i%4),ceil(i/4))
end
love.graphics.pop()

-------------------------------------------------------------------------------

function camera.new(instance)
	instance.viewport_size:attach(camera.update_buffers,instance)
end

function camera.delete(instance)
	local buffers=camera.buffers[instance]
	
	if not buffers then
		return
	end
	
	for _,pass in pairs(buffers) do
		if type(pass)=="table" then
			for _,buffer in ipairs(pass) do
				buffer:release()
			end
		else
			pass:release()
		end
	end
	
	camera.buffers[instance]=nil
end

function camera.update_buffers(instance)
	local buffers=camera.buffers[instance] or {}
	
	for _,pass in pairs(buffers) do
		if type(pass)=="table" then
			for _,buffer in ipairs(pass) do
				buffer:release()
			end
		else
			pass:release()
		end
	end
	
	buffers.skybox={
		love.graphics.newCanvas(
			instance.viewport_size.value.x,
			instance.viewport_size.value.y,
			{format="normal"}
		),
		depth=true
	}
	
	buffers.output={
		love.graphics.newCanvas(
			instance.viewport_size.value.x,
			instance.viewport_size.value.y,
			{
				format="normal"
			}
		),
		--[[
		depthstencil=love.graphics.newCanvas(
			instance.viewport_size.value.x,
			instance.viewport_size.value.y,
			{
				format="depth32f",
				readable=true
			}
		),
		]]
		depth=true
	}
	
	buffers.ssao=love.graphics.newCanvas(
		instance.viewport_size.value.x,
		instance.viewport_size.value.y
	)
	
	buffers.blur=love.graphics.newCanvas(
		instance.viewport_size.value.x,
		instance.viewport_size.value.y
	)
	
	camera.buffers[instance]=buffers
end

function camera.draw(camera_,view_buffer)
	local scene   = camera_.parent.value
	local buffers = camera.buffers[camera_]
	
	if getmetatable(scene)~=fage.class.scene then
		return
	end
	if not buffers then
		return
	end
	
	local projection=camera_.projection.value
	local view=temp_matrix4_1
	:set(camera_.transform.value:unpack())
	:inverse()
	
	local sky_mesh=fage.mesh.loaded.cube
	local sky_map=fage.cubemap.loaded[scene.sky_map.value]
	
	--Shaders
	local skybox         = backend.shader.skybox
	local forward_pass   = backend.shader.forward
	local ssao_pass      = backend.shader.ssao
	local ssao_blur_pass = backend.shader.ssao_blur
	local depth_pass     = backend.shader.depth
	
	love.graphics.push("all")
	love.graphics.setCanvas(buffers.output)
	love.graphics.clear(0,0,0,0)
	
	if sky_map and sky_map.reflection then
		love.graphics.setShader(skybox)
		skybox:send("projection","row",projection)
		skybox:send("view","row",
			skybox_view:set(view:unpack())
			:set_position(0,0,0)
		)
		skybox:send("sky_map",sky_map.reflection)
		love.graphics.draw(sky_mesh.drawable)
	end
	
	love.graphics.setShader(forward_pass)
	love.graphics.setDepthMode("lequal",true)
	
	forward_pass:send("projection","row",projection)
	forward_pass:send("view","row",view)
	
	if sky_map and sky_map.irradiance then
		forward_pass:send("irradiance_map",sky_map.irradiance)
	end
	
	temp_vector3_1[1],
	temp_vector3_1[2],
	temp_vector3_1[3]=camera_.transform.value:get_position()
	forward_pass:send("view_position",temp_vector3_1)
	
	for _,batch in pairs(scene.batch_render) do
		for _,instance_ in pairs(batch) do
			instance_:draw(scene,forward_pass)
		end
	end
	
	love.graphics.pop()
	
	--Draw output
	love.graphics.draw(
		buffers.output[1],
		0,buffers.output[1]:getHeight(),
		0,1,-1
	)
end

-------------------------------------------------------------------------------

return camera
end