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

local controls = core.controls

local anims = {
	frame = 1,

	play = function(self, image, anim)
		if not self.quads then
			self.quads = {}

			for y = 0, image:getHeight() - 16, 16 do
				for x = 0, image:getWidth() - 16, 16 do
					table.insert(self.quads, love.graphics.newQuad(x, y, 16, 16, image:getDimensions()))
				end
			end
		end

		self.frame = self.frame + love.timer.getDelta() / self[anim].speed

		if not self[anim].anim[math.floor(self.frame)] then
			self.frame = 1
		end

		return self.quads[self[anim].anim[math.floor(self.frame)]]
	end,

	idle_0 = {anim = {1, 2, 3, 4, 5, 6, 7, 8}, speed = 0.25},
	walk_0 = {anim = {9, 10, 11, 12, 13, 14, 15, 16}, speed = 0.025},
	idle_1 = {anim = {17, 18, 19, 20, 21, 22, 23, 24}, speed = 0.25},
	walk_1 = {anim = {25, 26, 27, 28, 29, 30, 31, 32}, speed = 0.025},
	jump_0 = {anim = {33, 34, 35, 36}, speed = 0.05},
}

local facing = 1
local rotation = 1
local cur_anim = "idle"

core.new_player = function()
	core.player = core.actor.new("player", core.assets.player, nil, 9, 11, {solid = true}, {
		draw = function(self, canvas)
			local height_offset = 1 + 0.05 * (self:get_height() - core.camera:get_height()) + 0.025

			canvas.draw(self:get_image(), anims:play(self:get_image(), cur_anim..'_'..rotation),
				(self:get_pos().x - core.camera:get_pos().x) * core.scale * height_offset,
				(self:get_pos().y - core.camera:get_pos().y) * core.scale * height_offset,
				self:get_yaw() * math.pi / 180, facing * core.scale / 16, core.scale / 16, 8, 8)
		end,

		is_grounded = function(self)
			if rawget(self, "grounded") then return true
			else return false end
		end,

		jump = function(self)
			if self:is_grounded() then
				rawset(self, "y_vel", -0.6)
			end
		end,

		on_step = function(self, dt)
			local j = core.utils.vector_normalize({x = controls.joystickX(), y = 0})

			if j.x > 0 then
				facing = 1
			elseif j.x < 0 then
				facing = -1
			end

			if self:is_grounded() then
				if cur_anim == "jump" then
					rotation = math.random(0, 1)
				end

				if j.x == 0 then
					cur_anim = "idle"
				else
					cur_anim = "walk"
				end
			elseif cur_anim == "idle" or cur_anim == "walk" then
				rotation = 0
				cur_anim = "jump"
			end

			local dist = core.utils.vector_length(j) / 4.4

			--[[if s < 0 then
				dist = dist / 2
				r = r / 4
			elseif s > 0 then
				dist = dist * 2
				r = r * 4
			end

			self:set_yaw(self:get_yaw() + r)--]]

			self:move(dist, self:get_yaw() + core.utils.d_atan(j.x, j.y))

			---[[
			local y0 = self:get_pos().y
			local yv = rawget(self, "y_vel") or 0

			local g = yv + 9.81 * dt * 0.25--0.16

			g = core.utils.gate(-5, g, 5)

			self:move(g, 90)

			if math.abs(self:get_pos().y - y0) < g / 2 then
				rawset(self, "grounded", true)
				rawset(self, "y_vel", 0)
			else
				rawset(self, "grounded", false)
				rawset(self, "y_vel", g)
			end
			--]]

			if self:get_pos().y > core.camera:get_pos().y + 26 then
				core.paused = true
				core.score = math.max(core.score, 0)
			end
		end,
	})
end
