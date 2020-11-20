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

local static = {
	push = function(self, actor, pos)
		local dist = core.utils.distance_point_line(pos, self.p1, self.p2)

		pos.x = pos.x + dist * core.utils.d_cos(self.dir) * 1.0001
		pos.y = pos.y + dist * core.utils.d_sin(self.dir) * 1.0001
	end,

	newindex = function()
		error("Error: Attempt to directly set a value in a terrain object. Please call one of the provided functions instead.")
	end,
}

function core.wall(x1, y1, x2, y2, dir)
	return setmetatable({}, {
		__index = {
			p1 = {x = x1, y = y1},
			p2 = {x = x2, y = y2},
			center = {x = (x1 + x2) / 2, y = (y1 + y2) / 2},
			dir = dir,

			push = static.push
		},

		__newindex = static.newindex,
		__metatable = false
	})
end
