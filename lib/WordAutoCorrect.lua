local WordAutoCorrectAPI = {}

local DICTIONARY = {}

function WordAutoCorrectAPI.loadDictionary(path)
	local stream = file:openReadStream(path)
	local buffer = data:createBuffer(stream:available())
	buffer:readFromStream(stream)
	buffer:setPosition(0)
	local data = buffer:readString(buffer:available())

	for line in string.gmatch(data, "([^\r\n]+)") do
		table.insert(DICTIONARY, line)
	end
	buffer:close()
	stream:close()
	return DICTIONARY
end

local function wagnerFischer(s1, s2)
	local len_s1, len_s2 = #s1, #s2
	if len_s1 > len_s2 then
		s1, s2 = s2, s1
		len_s1, len_s2 = len_s2, len_s1
	end

	local current_row = {}
	for i = 0, len_s1 do
		current_row[i] = i
	end

	for i = 1, len_s2 do
		local previous_row = current_row
		current_row = { [0] = i }
		for j = 1, len_s1 do
			local add = previous_row[j] + 1
			local delete = current_row[j - 1] + 1
			local change = previous_row[j - 1]
			if s1:sub(j, j) ~= s2:sub(i, i) then
				change = change + 1
			end
			current_row[j] = math.min(add, delete, change)
		end
	end

	return current_row[len_s1]
end

---@param word string
---@param threshold number?
---@param amount number?
---@return {[1]:string, [2]:number}[]
function WordAutoCorrectAPI.spellCheck(word, threshold, amount)

	local suggestions = {}
	local closest_dist = math.huge
	for _, correct_word in ipairs(DICTIONARY) do
		local distance = wagnerFischer(word, correct_word)
		closest_dist = math.min(closest_dist, distance)
		table.insert(suggestions, { correct_word, distance })
	end

	table.sort(suggestions, function(a, b) return a[2] < b[2] end)

	local top_suggestions = {}
	for i = 1, math.min(10, #suggestions) do
		table.insert(top_suggestions, suggestions[i])
	end

	return top_suggestions
end

return WordAutoCorrectAPI
