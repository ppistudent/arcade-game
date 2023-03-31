local class = {}

class.__index = class
class.new = function() end
class.super = getmetatable

function class:extend()
	local cls = setmetatable({}, self)
	for k, v in pairs(self) do
		if k:sub(1, 2) == "__" then
			cls[k] = v
		end
	end
	cls.__index = cls
	return cls
end

function class:implement(...)
	for _, interface in ipairs{...} do
		for k, v in pairs(interface) do
			if self[k] == nil and type(v) == "function" then
				self[k] = v
			end
		end
	end
	return self
end

function class.is(cls, type)
	cls = class.super(cls)
	while cls ~= nil do
		if cls == type then
			return true
		end
		cls = class.super(cls)
	end
	return false
end

function class:__call(...)
	local obj = setmetatable({}, self)
	obj:new(...)
	return obj
end

--[[
function class:__tostring()
	return "object"
end
--]]

return class
