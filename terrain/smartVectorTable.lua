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

local function vector_equals(a, b)
	return a.x == b.x and a.y == b.y and a.z == b.z
end

local function lessThan(a, b)
	if a.z < b.z then
		return true
	elseif a.z == b.z then
		if a.y < b.y then
			return true
		elseif a.y == b.y then
			if a.x < b.x then
				return true
			end
		end
	end

	return false
end

local function binaryInsert(svt, obj, left, right)
	left = left or 1
	right = right or svt.size()

	if left < right then
		local mid = math.floor((left + right) / 2)

		if vector_equals(obj.k, svt.getVector(mid)) then
			svt.table[mid] = obj
		elseif lessThan(obj.k, svt.getVector(mid)) then
			return binaryInsert(svt, obj, left, mid - 1)
		else 
			return binaryInsert(svt, obj, mid + 1, right)
		end
	else
		local ind = left
		if lessThan(svt.getVector(left), obj.k) then
			ind = ind + 1
		end

		table.insert(svt.table, ind, obj)

		for i = 1, svt.size() do
			local v = svt.getVector(i)
		end
	end
end

function core.smartVectorTable()
	local svt = {}

	svt.table = {}

	svt.set = function(keyVect, value)
		for _, v in ipairs(svt.table) do
			if vector_equals(keyVect, v.k) then
				v.v = value
				return
			end
		end

		local obj = {k = keyVect, v = value}

		if svt.size() == 0 then
			table.insert(svt.table, obj)
		elseif svt.size() == 1 then
			if lessThan(obj.k, svt.getVector(1)) then
				table.insert(svt.table, 1, obj)
			else
				table.insert(svt.table, obj)
			end
		else
			binaryInsert(svt, obj)
		end
	end

	svt.del = function(keyVect)
		for i, v in ipairs(svt.table) do
			if vector_equals(keyVect, v.k) then
				table.remove(svt.table, i)
				return
			end
		end
	end

	svt.get = function(keyVect, left, right)
		left = left or 1
		right = right or svt.size()

		if left <= right then
			local mid = math.floor((left + right) / 2)
			local midv = svt.getVector(mid)

			if vector_equals(keyVect, midv) then
				return svt.getValue(mid)
			elseif lessThan(keyVect, midv) then
				return svt.get(keyVect, left, mid - 1)
			else 
				return svt.get(keyVect, mid + 1, right)
			end
		end
	end

	svt.getVector = function(i)
		if not svt.table[i] then return end
		return svt.table[i].k
	end

	svt.getValue = function(i)
		if not svt.table[i] then return end
		return svt.table[i].v
	end

	svt.size = function()
		return #svt.table
	end

	return svt
end
