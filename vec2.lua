local class = require("class")
local vec2 = class:extend()

function vec2:new(x, y)
	local type = type(x)
	if type == "table" then
		assert(class.is(x, vec2), "Unrecognized parameter")
		self.x = x.x
		self.y = x.y
	elseif type == "number" then
		if y == nil then
			self.x = math.cos(x)
			self.y = math.sin(x)
		else
			self.x = x
			self.y = y
		end
	else
		self.x = 0
		self.y = 0
	end
end

do
	for k, v in pairs{
		__add = function(a, b) return a + b end,
		__sub = function(a, b) return a - b end,
		__mul = function(a, b) return a * b end,
		__div = function(a, b) return a / b end,
		__mod = function(a, b) return a % b end
	} do
		vec2[k] = function(a, b)
			if type(a) == "number" then
				return vec2(v(a, b.x), v(a, b.y))
			elseif type(b) == "number" then
				return vec2(v(a.x, b), v(a.y, b))
			else
				return vec2(v(a.x, b.x), v(a.y, b.y))
			end
		end
	end
end

function vec2.__eq(a, b)
	return a.x == b.x and a.y == b.y
end

-- Damn! Lua 5.1 not support __len metamethod! :<
function vec2.len(v)
	return math.sqrt(v:len2())
end

function vec2.len2(v)
	return v:dot(v)
end

function vec2.__unm(v)
	return vec2(-v.x, -v.y)
end

function vec2.dot(a, b)
	return a.x * b.x + a.y * b.y
end

function vec2.cross(a, b)
	if type(a) == "number" then
		return vec2(-a * b.y, a * b.x)
	elseif type(b) == "number" then
		return vec2(a.y * b, a.x * -b)
	else
		return a.x * b.y - a.y * b.x
	end
end

function vec2:rotate(v)
	local c, s
	if class.is(v, vec2) then
		c = v.x
		s = v.y
	else
		c = math.cos(v)
		s = math.sin(v)
	end
	return vec2(
		self.x * c - self.y * s,
		self.y * c + self.x * s
	)
end

function vec2.proj(a, b)
	return b * (a:dot(b) / b:dot(b))
end

function vec2:unpack()
	return self.x, self.y
end

function vec2:perpend()
	return vec2(-self.y, self.x)
end

function vec2:normalize()
	return self / self:len()
end

function vec2:angle()
	return math.atan2(self.y, self.x)
end

function vec2:__tostring()
	return ("(%g, %g)"):format(self.x, self.y)
end

return vec2
