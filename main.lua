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

core = {}

math.randomseed(os.time())
math.random()

local load = function(f)
	love.filesystem.load(f)()
end

load("utils.lua")
load("assets.lua")
load("controls.lua")

load("actors/actor.lua")
load("actors/camera.lua")
load("actors/player.lua")

load("terrain/smartVectorTable.lua")
load("terrain/wall.lua")
load("terrain/terrain.lua")
load("terrain/layer.lua")

local utils = core.utils
local assets = core.assets
local controls = core.controls

local actor = core.actor
local terra = core.terrain
local graphs = love.graphics
graphs.setDefaultFilter("nearest")

local TEXT_PERIOD = 100
local doText = TEXT_PERIOD
local text = "Load complete."

local show_touch_buttons = false

core.paused = true
core.scale = 40
core.practice = false

function love.load()
	assets.load()
	actor.init()
	core.new_camera()
	core.new_player()
	controls.init()
	terra.init()

	core.score = -14.5

	local x = 1

	for x = 0, 17 do
		for y = 4, 12 do
			if x == 0 or x == 17 or y == 12 then --or y % 2 ~= x % 2 then
				terra.create(x, y)
			end
		end
	end

	for x = 1, 16 do
		terra.create(x, 3)
	end

	core.create_layer(8, core.terrain.create, 1)
	core.create_layer(4, core.terrain.create)
end

function love.update(dt)
	if core.paused then return end

	for i, a in actor.iterate() do
		if a.on_step then
			a:on_step(dt)
		end
	end
end

core.draw_queue = {}
 
function love.draw()
	local width = love.graphics.getWidth()
	local height = love.graphics.getHeight()


	--rotate around the center of the screen according to the player's direction
	graphs.translate(width/2, height/2)
	graphs.rotate(-core.player:get_yaw() * math.pi / 180)
	--graphs.translate(-width/2, -height/2)

	local atan = core.utils.d_atan(0, -height/3) + core.camera:get_yaw()
	local c = height/3 * core.utils.d_cos(atan)
	local s = height/3 * core.utils.d_sin(atan)

	graphs.translate(c, s)

	----[[
	for i = -1, 3 do
		for v, t in terra.v_iterate(i-1) do
			t:draw(graphs, v)
		end

		if i % 2 == 0 then
			for _, a in actor.iterate(i / 2) do
				a:draw(graphs)
			end
		end
	end
	--]]

	for i = 1, #core.draw_queue do
		--core.draw_queue[i](graphs)
	end

	core.draw_queue = {}

	--[[for i = core.player:get_height() - 6, core.player:get_height() + 1 do
		for _, a in actor.iterate(i) do
			a:draw_overlay(graphs)
		end
	end--]]

	if doText > 0 then
		doText = doText - 1

		if doText == 0 then
			text = 0
		end
	end

	graphs.translate(-c, -s)

	--Reverse the rotation so that UI elements don't turn around as well.
	--graphs.translate(width/2, height/2)
	graphs.rotate(core.player:get_yaw() * math.pi / 180)
	graphs.translate(-width/2, -height/2)

	graphs.setColor(0, 0, 0)
	graphs.rectangle("fill", 0, 0, width, 32)
	graphs.setColor(1, 1, 1)

	core.print("FPS: "..love.timer.getFPS().." | Practice Mode: "..tostring(core.practice).." | Score: "..core.score)

	if core.paused then
		text = text.."\nPress spacebar to toggle practice mode. Press Enter to begin a new game."
	end

	graphs.print(text)

	if show_touch_buttons then
		graphs.draw(assets.arrows_alt, 0, graphs.getHeight() - 192, 0, 2, 2)
		graphs.draw(assets.arrows, graphs.getWidth() - 192, graphs.getHeight() - 192, 0, 2, 2)

		graphs.draw(assets.btn_plus, 0, 32, 0, 2, 2)
		graphs.draw(assets.btn_minus, 0, 128, 0, 2, 2)

		graphs.draw(assets.btn_up, graphs.getWidth() - 64, 32, 0, 2, 2)
		graphs.draw(assets.btn_down, graphs.getWidth() - 64, 128, 0, 2, 2)
	end
end

function love.mousepressed(x, y, button, istouch)
	istouch = false

	if istouch then
		show_touch_buttons = true

		if button == 1 then
			controls.click(x, y)
		end
	end
end

function love.mousereleased(x, y, button, istouch)
	if button == 1 then
	end
end

function love.keypressed(key, scancode, isrepeat)
	if not isrepeat then controls.process(key) end
end

function love.keyreleased(key)
	controls.unprocess(key)
end

function love.quit()
	graphs.print("Thanks for playing! Come back soon!")
end

function core.print(txt)
	doText = TEXT_PERIOD
	text = txt
end
