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

core.assets = {}

local this = core.assets
local load = love.graphics

local dir = "assets/"

local function loadNewImage(image)
	return load.newImage(dir..image..".png")
end

function this.load()
	this.missing = loadNewImage("nil")

	this.arrows = loadNewImage("arrows")
	this.arrows_alt = loadNewImage("arrows_alt")
	this.btn_plus = loadNewImage("btn_plus")
	this.btn_minus = loadNewImage("btn_minus")
	this.btn_up = loadNewImage("btn_up")
	this.btn_down = loadNewImage("btn_down")

	this.player = loadNewImage("player")

	this.black = loadNewImage("black")
	this.stone = loadNewImage("stone")
	this.stone_side = loadNewImage("stone_side")
end
