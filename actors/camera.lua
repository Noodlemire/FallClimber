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

local high_y = 11

core.new_camera = function()
	core.camera = core.actor.new("camera", nil, nil, 8.5, 8, nil, {
		on_step = function(self, dt)
			local y0 = math.floor(self:get_pos().y / 4) * 4 - 4

			if core.practice then
				local dist = core.player:get_pos().y - high_y

				if dist < 0 then
					self:move(-dist, 270)
					high_y = core.player:get_pos().y
				end
			else
				self:move(0.02 + core.score / 6000, 270)
				core.score = core.score + dt
			end

			local y1 = math.floor(self:get_pos().y / 4) * 4 - 4

			if y0 ~= y1 then
				for x = 1, 16 do
					core.terrain.clear(x, y0 - 1, 1)
				end

				for y = y1, y0 + 1 do
					core.terrain.create(0, y)
					core.terrain.create(17, y)

					for x = 0, 17 do
						core.terrain.clear(x, y + 26, 1)
					end
				end

				core.create_layer(y1, core.terrain.create)

				for x = 1, 16 do
					core.terrain.create(x, y1 - 1)
				end
			end
		end
	})
end
