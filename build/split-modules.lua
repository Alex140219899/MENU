local function read_lines(path)
	local t = {}
	for line in io.lines(path) do
		t[#t + 1] = line
	end
	return t
end

local function write_lines(path, lines)
	local f = assert(io.open(path, "w"))
	for _, l in ipairs(lines) do
		f:write(l, "\n")
	end
	f:close()
end

local function demote_locals(lines)
	local out = {}
	out[#out + 1] = "--- VigMenu module (loadfile from VigMenu.lua; moonloader/VigMenu/)"
	for _, line in ipairs(lines) do
		line = line:gsub("^local function ", "function ")
		line = line:gsub("^local UpdateUi =", "UpdateUi =")
		line = line:gsub("^local load_articles", "-- load_articles")
		table.insert(out, line)
	end
	return out
end

local root = arg[1] or "."
local src_path = root .. "/src/VigMenu.lua"
local src = read_lines(src_path)

local license_skip = {
	["local function vig_license_require_active"] = true,
	["local function vig_ensure_imgui_for_license"] = true,
	["function vig_open_license_ui"] = true,
	["local function process_vigkey_command"] = true,
	["local function vig_show_license_gate_on_startup"] = true,
}

local lic = {}
for i = 752, 1155 do
	local l = src[i]
	if not license_skip[l] then
		lic[#lic + 1] = l
	end
end
write_lines(root .. "/src/VigMenuLicense.lua", demote_locals(lic))

local upd = {}
for i = 1157, 1810 do
	upd[#upd + 1] = src[i]
end
for i = 1828, 1880 do
	upd[#upd + 1] = src[i]
end
write_lines(root .. "/src/VigMenuUpdate.lua", demote_locals(upd))

local function skip_range(i, line)
	if i >= 752 and i <= 1155 then
		if license_skip[line] then
			return false
		end
		return true
	end
	if i >= 1157 and i <= 1880 then
		if i >= 1812 and i <= 1826 then
			return false
		end
		return true
	end
	return false
end

local loader = {
	"",
	"local function vig_mod_path(name)",
	'\tlocal base = getWorkingDirectory():gsub("\\\\", "/")',
	'\tlocal p1 = base .. "/VigMenu/" .. name .. ".lua"',
	"\tif doesFileExist(p1) then return p1 end",
	'\tlocal p2 = base .. "/" .. name .. ".lua"',
	"\tif doesFileExist(p2) then return p2 end",
	"\treturn p1",
	"end",
	"",
	"local function vig_load_module(name)",
	"\tlocal path = vig_mod_path(name)",
	"\tlocal fn, err = loadfile(path)",
	"\tif not fn then",
	'\t\tprint("[gwarnn] модуль " .. name .. ": " .. tostring(err))',
	"\t\treturn false",
	"\tend",
	"\tlocal ok, run_err = pcall(fn)",
	"\tif not ok then",
	'\t\tprint("[gwarnn] загрузка " .. name .. ": " .. tostring(run_err))',
	"\t\treturn false",
	"\tend",
	"\treturn true",
	"end",
	"",
	'if not vig_load_module("VigMenuLicense") then',
	'\tprint("[gwarnn] СТОП: положите VigMenuLicense.lua в moonloader/VigMenu/")',
	"end",
	'if not vig_load_module("VigMenuUpdate") then',
	'\tprint("[gwarnn] СТОП: положите VigMenuUpdate.lua в moonloader/VigMenu/")',
	"end",
}

local out = {}
local inserted = false
for i, l in ipairs(src) do
	if not skip_range(i, l) then
		out[#out + 1] = l
	end
	if not inserted and l:match("^return ok and doesFileExist%(dest%)$") then
		for _, ll in ipairs(loader) do
			out[#out + 1] = ll
		end
		inserted = true
	end
end

write_lines(src_path, out)
print("license:", #lic, "update:", #upd, "main:", #out, "loader:", inserted)
