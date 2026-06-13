local map = {
	a = "ᴀ",
	b = "ʙ",
	c = "ᴄ",
	d = "ᴅ",
	e = "ᴇ",
	f = "ꜰ",
	g = "ɢ",
	h = "ʜ",
	i = "ɪ",
	j = "ᴊ",
	k = "ᴋ",
	l = "ʟ",
	m = "ᴍ",
	n = "ɴ",
	o = "ᴏ",
	p = "ᴘ",
	q = "ǫ",
	r = "ʀ",
	s = "ѕ",
	t = "ᴛ",
	u = "ᴜ",
	v = "ᴠ",
	w = "ᴡ",
	x = "x",
	y = "ʏ",
	z = "ᴢ",
}

local API = {}

function API.smallcaps(str)
	local out = {}
	for i = 1, #str, 1 do
		local char = string.sub(str, i, i)
		if map[char] then
			out[i] = map[char]
		else
			out[i] = char
		end
	end

	return table.concat(out)
end

return API
