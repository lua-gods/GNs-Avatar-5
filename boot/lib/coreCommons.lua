local api = {}

local id = 0

---@param paths string[]
---@param tick fun(path:string,ok: boolean)?
---@param finish fun(errors:{errored:boolean,path:string,msg:string}[])?
function api.asyncLoadDir(paths,tick,finish)
	id = id + 1
	local model = models:newPart("loader"..id, "SKULL")
	local i = 1
	local errors = {}
	
	local function process()
		local path = paths[i]
		if path then
			local ok, result = pcall(require,path)
			if ok then
				errors[i] = {path=path}
			else
				errors[i] = {errored=true,path=path,msg=result}
			end
			if tick then
				tick(path,ok)
			end
			i = i + 1
		else
			if finish then
				finish(errors)
				BOOT_CLOCK:remove(process)
			end
			model:remove()
		end
		
	end
	BOOT_CLOCK:register(process)
end

return api
