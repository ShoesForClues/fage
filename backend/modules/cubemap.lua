return function(luma,fage,backend)
local lmath=luma:import "lmath"

-------------------------------------------------------------------------------

local cubemap={}

-------------------------------------------------------------------------------

local face_projection=lmath.matrix4.new()
:set_perspective(90,1,0.5,1000)

local view=lmath.matrix4.new()

local face_lookup_matrix={
	lmath.matrix4.new():set_look(1,0,0,0,1,0),
	lmath.matrix4.new():set_look(-1,0,0,0,1,0),
	lmath.matrix4.new():set_look(0,-1,0,0,0,-1),
	lmath.matrix4.new():set_look(0,1,0,0,0,1),
	lmath.matrix4.new():set_look(0,0,-1,0,1,0),
	lmath.matrix4.new():set_look(0,0,1,0,1,0)
}

local face_lookup_matrix_2={
	lmath.matrix4.new():set_look(-1,0,0,0,1,0),
	lmath.matrix4.new():set_look(1,0,0,0,1,0),
	lmath.matrix4.new():set_look(0,-1,0,0,0,-1),
	lmath.matrix4.new():set_look(0,1,0,0,0,1),
	lmath.matrix4.new():set_look(0,0,-1,0,1,0),
	lmath.matrix4.new():set_look(0,0,1,0,1,0)
}

local face_buffers={hd={},ld={}}
for i=1,6 do
	face_buffers.hd[i]=love.graphics.newCanvas(
		512,512,
		{format="normal"}
	)
	face_buffers.ld[i]=love.graphics.newCanvas(
		32,32,
		{format="normal"}
	)
end

-------------------------------------------------------------------------------

function cubemap.load(source)
	local extension=source:match("^.+(%..+)$"):lower()
	
	local cubemap_={}
	
	if extension==".hdr" then
		local hdr_texture=love.graphics.newImage(source)
		
		local hdr_to_cube=backend.shader.hdr_to_cube
		local convolute=backend.shader.convolute
		
		local cube_mesh=fage.mesh.loaded.cube
		
		love.graphics.push("all")
		love.graphics.setShader(hdr_to_cube)
		hdr_to_cube:send("equirectangular_map",hdr_texture)
		hdr_to_cube:send("projection","row",face_projection)
		for i=1,6 do
			love.graphics.setCanvas(face_buffers.hd[i])
			hdr_to_cube:send("view","row",
				view:set(face_lookup_matrix[i]:unpack())
				:inverse()
			)
			love.graphics.draw(cube_mesh.drawable)
		end
		love.graphics.pop()
		
		local image_datas={}
		for i=1,6 do
			image_datas[i]=face_buffers.hd[i]:newImageData()
		end
		
		cubemap_.reflection=love.graphics.newCubeImage(image_datas)
		
		for _,image_data in ipairs(image_datas) do
			image_data:release()
		end
		
		love.graphics.push("all")
		love.graphics.setShader(convolute)
		convolute:send("environment_map",cubemap_.reflection)
		convolute:send("projection","row",face_projection)
		for i=1,6 do
			love.graphics.setCanvas(face_buffers.ld[i])
			convolute:send("view","row",
				view:set(face_lookup_matrix_2[i]:unpack())
				:rotate_euler(math.rad(180),0,0)
				:inverse()
			)
			love.graphics.draw(cube_mesh.drawable)
		end
		love.graphics.pop()
		
		for i=1,6 do
			image_datas[i]=face_buffers.ld[i]:newImageData()
		end
		
		cubemap_.irradiance=love.graphics.newCubeImage(image_datas)
		
		for _,image_data in ipairs(image_datas) do
			image_data:release()
		end
		
		hdr_texture:release()
	else
		cubemap_.reflection=love.graphics.newCubeImage(source)
	end
	
	return cubemap_
end

function cubemap.delete(cubemap_)
	if cubemap_.reflection then
		cubemap_.reflection:release()
	end
	if cubemap_.irradiance then
		cubemap_.irradiance:release()
	end
	if cubemap_.specular then
		cubemap_.specular:release()
	end
end

-------------------------------------------------------------------------------

return cubemap
end