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

core.controls = {}
local this = core.controls

local keyboard = love.keyboard
local mouse = love.mouse
local w = love.graphics.getWidth()
local h = love.graphics.getHeight()

function this.init()
	this.up = 'up'
	this.down = 'down'
	this.left = 'left'
	this.right = 'right'
	this.sprint = 'w'
	this.sneak = 's'
	this.r_left = 'a'
	this.r_right = 'd'
	this.toggle_practice = "space"
	this.start = "return"

	local buttonMap = 
	{
		--[button] = function()
		[this.up] = function()
			core.player:jump()
		end,
		[this.toggle_practice] = function()
			if core.paused then
				core.practice = not core.practice
			end
		end,
		[this.start] = function()
			if core.paused then
				core.paused = false
				love.load()
			end
		end,
	}

	local unButtonMap = 
	{
		--[button] = function()
	}

	function this.process(key)
		if type(buttonMap[key]) == "function" then
			buttonMap[key]()
		end
	end

	function this.unprocess(key)
		if type(unButtonMap[key]) == "function" then
			unButtonMap[key]()
		end
	end

	function this.click(x, y)
		if 0 <= x and x <= 64 and 32 <= y and y <= 96 then
			this.process('+')
		elseif 0 <= x and x <= 64 and 128 <= y and y <= 192 then
			this.process('-')
		elseif w - 64 <= x and x <= w and 32 <= y and y <= 96 then
			this.process('space')
		elseif w - 64 <= x and x <= w and 128 <= y and y <= 192 then
			this.process('lshift')
		end
	end

	local function checkTouches(x1, y1, x2, y2)
		local touches = love.touch.getTouches()

		for i = 1, #touches do
			local tx, ty = love.touch.getPosition(touches[i])

			if x1 <= tx and tx <= x2 and y1 <= ty and ty <= y2 then
				return true
			end
		end

		return false
	end

	--lower bound key and upper bound key
	local function makejoystick(lbkey, ubkey, x1, y1, x2, y2, x3, y3, x4, y4)
		local value = 0

		local mx, my = mouse.getPosition()

		if keyboard.isDown(lbkey) or checkTouches(x1, y1, x2, y2) then--(mouse.isDown(1) and x1 <= mx and mx <= x2 and y1 <= my and my <= y2) then
			value = value - 1
		end

		if keyboard.isDown(ubkey) or checkTouches(x3, y3, x4, y4) then --(mouse.isDown(1) and x3 <= mx and mx <= x4 and y3 <= my and my <= y4) then
			value = value + 1
		end

		return value
	end

	function this.joystickX()
		return makejoystick(this.left, this.right, w - 192, h - 192, w - 128, h, w - 64, h - 192, w, h)
	end

	function this.joystickY()
		return makejoystick(this.down, this.up, w - 192, h - 64, w, h, w - 192, h - 192, w, h - 128)
	end

	--[[function this.joystickS()
		return makejoystick(this.sneak, this.sprint, 0, h - 64, 192, h, 0, h - 192, 192, h - 128)
	end

	function this.joystickR()
		return makejoystick(this.r_left, this.r_right, 0, h - 192, 64, h, 128, h - 192, 192, h)
	end--]]
end
