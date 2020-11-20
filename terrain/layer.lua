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

local W = 1
local _ = 0
local X = -1

local last_layer = nil

local layers = {
	{
		W, _, _, _, _, X, X, X, X, X, X, _, _, _, _, W,
		X, W, W, _, _, _, W, X, X, W, _, _, _, W, W, X,
		X, X, W, W, _, _, _, W, W, _, _, _, W, W, X, X,
		X, _, _, _, _, _, _, _, _, _, _, _, _, _, _, X,
	},
	{
		X, X, X, X, X, W, _, _, _, _, W, X, X, X, X, X,
		X, X, X, X, X, X, W, _, _, W, X, X, X, X, X, X,
		_, _, _, _, _, X, W, _, _, W, X, _, _, _, _, _,
		_, W, W, X, _, _, _, _, _, _, _, _, X, W, W, _,
	},
	{
		_, _, _, _, _, _, _, _, W, X, X, X, X, X, W, W,
		W, X, _, _, _, _, _, _, _, _, _, _, _, _, _, _,
		X, W, W, W, W, W, W, W, W, W, W, W, W, W, _, _,
		X, X, X, X, X, X, X, _, _, _, _, _, _, _, _, W,
	},
	{
		W, W, X, X, X, X, X, W, _, _, _, _, _, _, _, _,
		_, _, _, _, _, _, _, _, _, _, _, _, _, _, X, W,
		_, _, W, W, W, W, W, W, W, W, W, W, W, W, W, X,
		W, _, _, _, _, _, _, _, _, X, X, X, X, X, X, X,
	},
	{
		W, X, _, _, _, _, _, _, _, X, W, W, X, _, _, _,
		X, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _,
		_, _, X, W, W, X, _, _, _, _, _, _, _, _, _, X,
		_, _, _, _, _, _, _, _, w, _, _, _, _, _, X, W,
	},
	{
		_, X, W, W, W, W, W, _, _, W, W, W, W, W, X, X,
		_, X, W, _, _, _, W, _, _, W, _, _, _, W, X, X,
		_, _, W, _, W, _, _, _, _, _, _, W, _, W, X, X,
		W, _, _, _, W, W, W, W, W, W, W, W, _, _, _, _,
	},
	{
		X, _, _, _, _, _, _, X, X, _, _, _, _, _, _, X,
		X, _, _, X, _, _, X, W, W, X, _, _, _, _, _, X,
		X, _, _, W, _, _, _, X, X, _, _, _, W, X, _, X,
		X, _, W, X, W, _, _, _, _, _, _, _, X, W, _, X,
	},
	{
		_, _, W, W, W, X, X, _, W, X, X, W, W, W, _, _,
		_, _, _, W, W, X, _, _, _, X, X, W, W, _, _, _,
		_, _, _, W, W, X, X, _, _, _, X, W, W, _, _, _,
		_, _, W, W, W, X, X, W, _, X, X, W, W, W, _, _,
	},
	{
		_, W, X, _, _, _, _, _, _, _, _, _, _, X, W, _,
		_, _, W, _, _, _, W, _, _, W, _, _, _, W, _, _,
		_, _, X, W, _, W, _, _, _, _, W, _, W, X, _, _,
		X, _, _, X, _, X, X, _, _, X, X, _, X, _, _, X,
	},
	{
		W, _, W, X, X, X, X, W, W, W, W, W, W, _, _, _,
		X, _, _, X, X, X, X, W, W, _, _, _, _, W, _, _,
		X, W, _, X, X, X, X, W, W, _, _, _, _, _, _, _,
		X, _, _, X, X, X, X, W, _, _, _, _, _, W, W, W,
	},
	{
		_, _, _, _, _, _, _, _, W, X, X, X, _, _, _, X,
		X, W, X, _, _, _, _, W, W, X, X, X, W, _, X, X,
		_, _, _, _, _, _, _, W, W, X, X, X, X, _, _, X,
		_, _, _, X, W, X, _, _, W, X, X, X, X, W, _, X,
	},
}

function core.create_layer(height, tile, n)
	local l = n or last_layer

	while l == last_layer do
		l = math.random(#layers)
	end

	last_layer = l

	local layer = layers[l]

	for i = 0, #layer - 1 do
		local x = i % 16 + 1
		local y = height + math.floor(i / 16)

		if layer[i+1] == 1 or (layer[i+1] == -1 and math.random(1, 3) == 1) then
			tile(x, y)
		end
	end
end
