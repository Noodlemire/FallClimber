--[[
Fall Climber
Copyright (C) 2020 Noodlemire

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
--]]

core.terrain = {}
local map, vmap



function core.terrain.init()
	map = core.smartVectorTable()
	vmap = core.smartVectorTable()
end



local u = core.utils

local function quadrangle(mesh, x1, y1, x2, y2, x3, y3, x4, y4)
	mesh:setVertices({{x1, y1, 0, 1}, {x2, y2, 1, 1}, {x3, y3, 1, 0}, {x4, y4, 0, 0}})

	return mesh
end

local static = {
	draw = function(self, canvas, v)
		if self:get_image() then
			local x, y, z = v.x, v.y, math.ceil(v.z / 2)

			local d1 = not core.terrain.v_get(x + 1, y, v.z)
			local d2 = not core.terrain.v_get(x - 1, y, v.z)
			local d3 = not core.terrain.v_get(x, y + 1, v.z)
			local d4 = not core.terrain.v_get(x, y - 1, v.z)
			local d5 = not core.terrain.v_get(x, y, v.z + 1)

			if not (d1 or d2 or d3 or d4 or d5) then return end

			local height_offset = 1 + 0.05 * (z - core.camera:get_height() + 1)
			local depth_offset = height_offset - 0.05

			local rel_x, rel_y = x * core.scale, y * core.scale

			local top_x = (rel_x - core.camera:get_pos().x * core.scale) * height_offset
			local top_y = (rel_y - core.camera:get_pos().y * core.scale) * height_offset -- - 8 + canvas.getHeight() / 2 

			local t_x, t_y = 0, 0
			local h2 = height_offset * core.scale

			if v.z % 2 == 1 then
				local bot_x = (rel_x - core.camera:get_pos().x * core.scale) * depth_offset
				local bot_y = (rel_y - core.camera:get_pos().y * core.scale) * depth_offset

				local b_x, b_y = (bot_x - top_x), (bot_y - top_y)
				local h1 = depth_offset * core.scale

				if d2 and x > core.camera:get_pos().x then
					canvas.draw(quadrangle(self.mesh[2], b_x, b_y, b_x, b_y + h1, t_x, t_y + h2, t_x, t_y),
						top_x, top_y, 0, 1, 1, core.scale / 2, core.scale / 2)
				elseif d1 and x + 1 < core.camera:get_pos().x then
					canvas.draw(quadrangle(self.mesh[1], b_x + h1, b_y, b_x + h1, b_y + h1, t_x + h2, t_y + h2, t_x + h2, t_y),
						top_x, top_y, 0, 1, 1, core.scale / 2, core.scale / 2)
				end

				if d4 and y > core.camera:get_pos().y then
					canvas.draw(quadrangle(self.mesh[4], b_x + h1, b_y, b_x, b_y, t_x, t_y, t_x + h2, t_y),
						top_x, top_y, 0, 1, 1, core.scale / 2, core.scale / 2)
				elseif d3 and y + 1 < core.camera:get_pos().y then
					canvas.draw(quadrangle(self.mesh[3], b_x, b_y + h1, b_x + h1, b_y + h1, t_x + h2, t_y + h2, t_x, t_y + h2),
						top_x, top_y, 0, 1, 1, core.scale / 2, core.scale / 2)
				end
			elseif d5 then
				self.mesh[5]:setTexture(self:get_image())
				canvas.draw(quadrangle(self.mesh[5], t_x, t_y + h2, t_x + h2, t_y + h2, t_x + h2, t_y, t_x, t_y),
					top_x, top_y, 0, 1, 1, core.scale / 2, core.scale / 2)
			elseif z - core.camera:get_height() == 1 then
				self.mesh[5]:setTexture(core.assets.black)
				canvas.draw(quadrangle(self.mesh[5], t_x, t_y + h2, t_x + h2, t_y + h2, t_x + h2, t_y, t_x, t_y),
					top_x, top_y, 0, 1, 1, core.scale / 2, core.scale / 2)
			end
		end
	end,

	get_hardness = function(self)
		return rawget(self, "hardness")
	end,
	get_image = function(self)
		return rawget(self, "image")
	end,
	get_side_image = function(self)
		return rawget(self, "side_image")
	end,
	get_name = function(self)
		return rawget(self, "name")
	end,

	newindex = function()
		error("Error: Attempt to directly set a value in a terrain object. Please call one of the provided functions instead.")
	end,
}



function core.terrain.new(name, image, side_image, hardness, x, y, height)
	x = u.round(x)
	y = u.round(y)

	height = u.round(height or 0)

	local a = -0.9
	local b = 0.9

	local terrain = setmetatable({
		name = name,
		image = image,
		side_image = side_image or image,
		hardness = hardness
	}, {
		__index = {
			mesh = {},
			collision = {
				core.wall(x+a, y+a, x+b, y+a, 270, 1), --bottom
				core.wall(x+b, y+a, x+b, y+b, 0, 1), --right
				core.wall(x+b, y+b, x+a, y+b, 90, 1), --top
				core.wall(x+a, y+b, x+a, y+a, 180, 1), --left
			},

			draw = static.draw,
			get_hardness = static.get_hardness,
			get_image = static.get_image,
			get_side_image = static.get_side_image,
			get_name = static.get_name,
		},

		__newindex = static.newindex,
		__metatable = false
	})

	for i = 1, 5 do
		terrain.mesh[i] = love.graphics.newMesh({{0, 1, 0, 1}, {1, 1, 1, 1}, {1, 0, 1, 0}, {0, 0, 0, 0}})
		if i == 5 then
			terrain.mesh[i]:setTexture(image)
		else
			terrain.mesh[i]:setTexture(side_image or image)
		end
	end

	map.set({x=x, y=y, z=height}, terrain)
	vmap.set({x=x, y=y, z=height * 2}, terrain)
	if height > 0 then
		vmap.set({x=x, y=y, z=height * 2 - 1}, terrain)
	end

	return terrain
end

function core.terrain.clear(x, y, height)
	x = u.round(x)
	y = u.round(y)

	height = u.round(height or 0)

	map.del({x=x, y=y, z=height})
	vmap.del({x=x, y=y, z=height * 2})
	vmap.del({x=x, y=y, z=height * 2 - 1})
end

function core.terrain.size()
	return map.size()
end

function core.terrain.v_size()
	return vmap.size()
end

function core.terrain.get(x, y, z)
	local v = x

	if type(x) ~= "table" then
		v = {
			x = u.round(x),
			y = u.round(y),
			z = u.round(z or 1),
		}
	else
		v.x = u.round(v.x)
		v.y = u.round(v.y)
		v.z = u.round(v.z or 1)
	end

	return map.get(v)
end

function core.terrain.v_get(x, y, z)
	local v = x

	if type(x) ~= "table" then
		v = {
			x = u.round(x),
			y = u.round(y),
			z = u.round(z or 1),
		}
	else
		v.x = u.round(v.x)
		v.y = u.round(v.y)
		v.z = u.round(v.z or 1)
	end

	return vmap.get(v)
end

function core.terrain.iterate()
	local i = 0

	return function()
		i = i + 1

		if i <= core.terrain.size() then
			return map.getVector(i), map.getValue(i)
		end
	end
end

function core.terrain.v_iterate(layer)
	local i = 0

	return function()
		i = i + 1

		if i <= core.terrain.v_size() then
			while vmap.getVector(i) and vmap.getVector(i).z < layer do
				i = i + 1
			end

			if vmap.getVector(i) and vmap.getVector(i).z == layer then
				return vmap.getVector(i), vmap.getValue(i)
			end
		end
	end
end



function core.terrain.create(x, y)
	core.terrain.new("stone", core.assets.stone, core.assets.stone_side, 3, x, y, 1)
end
