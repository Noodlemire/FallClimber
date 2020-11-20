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

core.utils = {}



core.utils.NEIGHBORS5 = {
	{x = 1, y = 0, z = 0},
	{x = -1, y = 0, z = 0},
	{x = 0, y = 1, z = 0},
	{x = 0, y = -1, z = 0},
	{x = 0, y = 0, z = 1},
}

core.utils.NEIGHBORS9 = {
	{x = -1, y = -1, z = 0},
	{x = 0, y = -1, z = 0},
	{x = 1, y = -1, z = 0},
	{x = -1, y = 0, z = 0},
	{x = 0, y = 0, z = 0},
	{x = 1, y = 0, z = 0},
	{x = -1, y = 1, z = 0},
	{x = 0, y = 1, z = 0},
	{x = 1, y = 1, z = 0},
}



function core.utils.copy(t)
	local c = {}

	for k, v in pairs(t) do
		if type(v) == "table" then
			c[k] = core.utils.copy(v)
		else
			c[k] = v
		end
	end

	return c
end

function core.utils.copy_functions(t)
	local c = {}

	for k, v in pairs(t) do
		if type(v) == "function" then
			c[k] = v
		end
	end

	return c
end

function core.utils.direction(p1, p2)
	return core.utils.d_atan(p2.y - p1.y, p2.x - p1.x)
end

function core.utils.distance(p1, p2)
	return math.sqrt((p2.x - p1.x)^2 + (p2.y - p1.y)^2)
end

function core.utils.distance_point_line(p0, lp1, lp2)
	return math.abs((lp2.y - lp1.y) * p0.x - (lp2.x - lp1.x) * p0.y + lp2.x * lp1.y - lp2.y * lp1.x) / core.utils.distance(lp1, lp2)
end

function core.utils.draw_line(a, b)
	local x1 = (a.x - core.camera:get_pos().x) * core.scale
	local y1 = (a.y - core.camera:get_pos().y) * core.scale
	local x2 = (b.x - core.camera:get_pos().x) * core.scale
	local y2 = (b.y - core.camera:get_pos().y) * core.scale

	table.insert(core.draw_queue, function(canvas)
		canvas.line(x1, y1, x2, y2)
	end)
end

function core.utils.gate(a, b, c)
	return math.max(a, math.min(b, c))
end

function core.utils.point_on_line(p0, lp1, lp2)
	return math.min(lp1.x, lp2.x) <= p0.x and p0.x <= math.max(lp1.x, lp2.x) and math.min(lp1.y, lp2.y) <= p0.y and p0.y <= math.max(lp1.y, lp2.y)
end

function core.utils.point_orientation(a, b, c)
	local ori = (b.y - a.y) * (c.x - b.x) - (b.x - a.x) * (c.y - b.y)

	if ori < 0 then
		return -1
	elseif ori > 0 then
		return 1
	else
		return 0
	end
end

function core.utils.line_intersects(a1, a2, b1, b2)

	local o1 = core.utils.point_orientation(b1, b2, a1)
	local o2 = core.utils.point_orientation(b1, b2, a2)
	local o3 = core.utils.point_orientation(a1, a2, b1)
	local o4 = core.utils.point_orientation(a1, a2, b2)

	--return
	if		(((o1 < 0 and o2 > 0) or (o1 > 0 and o2 < 0)) and ((o3 < 0 and o4 > 0) or (o3 > 0 and o4 < 0))) or
			(o1 == 0 and core.utils.point_on_line(a1, a2, b1)) or
			(o2 == 0 and core.utils.point_on_line(a1, b2, b1)) or
			(o3 == 0 and core.utils.point_on_line(a2, a1, b2)) or
			(o4 == 0 and core.utils.point_on_line(a2, b1, b2)) then
		core.utils.draw_line(a1, a2)
		core.utils.draw_line(b1, b2)

		return true
	else
		return false
	end
end

function core.utils.round(n)
	return math.floor(tonumber(n) + 0.5)
end

function core.utils.d_cos(n)
	return math.cos(n * math.pi / 180)
end

function core.utils.d_sin(n)
	return math.sin(n * math.pi / 180)
end

function core.utils.d_tan(n)
	return math.tan(n * math.pi / 180)
end

function core.utils.d_atan(a, b)
	return math.atan2(b, a) * 180 / math.pi
end

function core.utils.vector_length(v)
	return math.sqrt(v.x^2 + v.y^2)
end

function core.utils.vector_normalize(v)
	local length = core.utils.vector_length(v)

	if length == 0 then
		return v
	else
		return {x = v.x / length, y = v.y / length}
	end
end
