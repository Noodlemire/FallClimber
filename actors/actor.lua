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

core.actor = {}
local actors



function core.actor.init()
	actors = {}
end



local u = core.utils

local draw = function(self, canvas, image)
	if not image then return end

	local height_offset = 1 + 0.05 * (self:get_height() - core.camera:get_height()) + 0.025

	canvas.draw(image,
		(self:get_pos().x - core.camera:get_pos().x) * core.scale * height_offset,
		(self:get_pos().y - core.camera:get_pos().y) * core.scale * height_offset,
		self:get_yaw() * math.pi / 180, core.scale / 16, core.scale / 16, 8, 8) --1: 8, 2: 4
end

local static = {
	die = function(self)
		actors[self:get_id()] = false
	end,

	draw = function(self, canvas)
		draw(self, canvas, self:get_image())
	end,

	draw_overlay = function(self, canvas)
		draw(self, canvas, self:get_overlay())
	end,

	get_height = function(self)
		return rawget(self, "height")
	end,
	get_hp = function(self)
		return rawget(self, "hp")
	end,
	get_id = function(self)
		return rawget(self, "id")
	end,
	get_image = function(self)
		return rawget(self, "image")
	end,
	get_max_hp = function(self)
		return rawget(self, "max_hp")
	end,
	get_name = function(self)
		return rawget(self, "name")
	end,
	get_overlay = function(self)
		return rawget(self, "image_over")
	end,
	get_pos = function(self)
		return rawget(self, "pos")
	end,
	get_yaw = function(self)
		return rawget(self, "yaw")
	end,

	is_solid = function(self)
		if rawget(self, "solid") then return true
		else return false end
	end,

	move = function(self, dist, dir)
		if dist < 0 then
			dist = -dist
			dir = dir + 180
		end

		local step_dist = math.min(dist, 0.5)

		--print(step_dist)

		local pos = {
			x = self:get_pos().x + step_dist * core.utils.d_cos(dir or self:get_yaw()),
			y = self:get_pos().y + step_dist * core.utils.d_sin(dir or self:get_yaw())
		}

		if self:is_solid() then
			local posChanged = true
			local limit = 99

			while posChanged and limit > 0 do
				posChanged = false
				limit = limit - 1

				for i = 1, #core.utils.NEIGHBORS9 do
					local npos = core.utils.copy(self:get_pos())
					npos.x = npos.x + core.utils.NEIGHBORS9[i].x
					npos.y = npos.y + core.utils.NEIGHBORS9[i].y

					local terra = core.terrain.get(npos.x, npos.y, self:get_height())

					if terra then
						local mindist = step_dist
						local closest_wall = nil

						for c = 1, #terra.collision do
							if core.utils.line_intersects(self:get_pos(), pos, terra.collision[c].p1, terra.collision[c].p2) then
								local newdist = core.utils.distance_point_line(self:get_pos(), terra.collision[c].p1, terra.collision[c].p2)

								if newdist < mindist then
									mindist = newdist
									closest_wall = terra.collision[c]
								end
							end
						end

						if closest_wall then
							closest_wall:push(self, pos)
							posChanged = true
						end
					end
				end
			end
		end

		self:set_pos(pos)

		if dist > step_dist then --and not pushed then
			return self:move(dist - step_dist, dir)
		else
			return self
		end
	end,

	set_hp = function(self, hp)
		if hp <= 0 then
			self:die()
		else
			rawset(self, "hp", math.min(self:get_max_hp(), hp))
		end
	end,

	set_height = function(self, height)
		rawset(self, "height", tonumber(height))
	end,
	set_pos = function(self, pos)
		pos = pos or self:get_pos()
		rawset(self:get_pos(), "x", tonumber(pos.x or self:get_pos().x))
		rawset(self:get_pos(), "y", tonumber(pos.y or self:get_pos().y))
	end,

	set_yaw = function(self, yaw)
		yaw = tonumber(yaw) % 360
		rawset(self, "yaw", yaw)
	end,

	newindex = function()
		error("Error: Attempt to directly set a value in an actor object. Please call one of the provided functions instead.")
	end,
}



function core.actor.new(name, image, image_over, x, y, properties, functions, init_func)
	properties = properties or {}

	properties.name = tostring(name)
	properties.image = image
	properties.image_over = image_over
	properties.pos = setmetatable({x = tonumber(x), y = tonumber(y)}, {
		__newindex = static.newindex,
		__metatable = {},
	})
	properties.height = properties.height or 1
	properties.yaw = properties.yaw or 0
	properties.id = #actors + 1

	properties.max_hp = properties.max_hp or 1
	properties.hp = properties.max_hp

	functions = functions and u.copy_functions(functions) or {}

	functions.die = functions.die or static.die
	functions.draw = functions.draw or static.draw
	functions.draw_overlay = functions.draw_overlay or static.draw_overlay
	functions.get_height = functions.get_height or static.get_height
	functions.get_hp = functions.get_hp or static.get_hp
	functions.get_id = functions.get_id or static.get_id
	functions.get_image = functions.get_image or static.get_image
	functions.get_max_hp = functions.get_max_hp or static.get_max_hp
	functions.get_name = functions.get_name or static.get_name
	functions.get_overlay = functions.get_overlay or static.get_overlay
	functions.get_pos = functions.get_pos or static.get_pos
	functions.get_yaw = functions.get_yaw or static.get_yaw
	functions.is_solid = functions.is_solid or static.is_solid
	functions.move = functions.move or static.move
	functions.set_height = functions.set_height or static.set_height
	functions.set_hp = functions.get_hp or static.set_hp
	functions.set_pos = functions.set_pos or static.set_pos
	functions.set_yaw = functions.set_yaw or static.set_yaw

	local actor = setmetatable(properties, {
		__index = functions,
		__newindex = static.newindex,
		__metatable = {},
	})

	if init_func then
		actor = init_func(actor)
	end

	if actor then
		actors[actor:get_id()] = actor
		return actor
	end
end

function core.actor.count()
	return #actors
end

function core.actor.get(id)
	return actors[id]
end

function core.actor.iterate(layer)
	local i = 0

	return function()
		i = i + 1

		while (core.actor.get(i) and layer and core.actor.get(i):get_height() < layer) or (not core.actor.get(i) and i < core.actor.count()) do
			i = i + 1
		end

		if core.actor.get(i) and (not layer or core.actor.get(i):get_height() == layer) then
			return i, core.actor.get(i)
		end
	end
end
