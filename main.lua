--- @since 26.8.15
--- @sync entry
---
--- Один список layout-views. Меняет rt.mgr.ratio = { parent, current, preview }.

local config = {
	--- parent / current / preview
	--- @type table<string, integer[]>
	presets = {
		-- Три панели, как в yazi.toml
		default = { 20, 30, 50 },
		-- Больше список файлов
		files = { 10, 60, 30 },
		-- Без parent: список | preview
		dual = { 0, 50, 50 },
		-- Крупный preview
		preview = { 0, 25, 75 },
		-- Только preview (бывший max-preview)
		focus = { 0, 0, 100 },
		-- Только список (бывший min-preview / list)
		list = { 0, 100, 0 },
        -- preview-and-files
        preview_and_files = { 10, 30, 60 },
	},
	--- @type string[]
	order = { "default", "files", "dual", "preview", "focus", "list" },
	notify = true,
}
--- @param a any
--- @param b any
--- @param c any
--- @return integer?, integer?, integer?, string?
local function parse_triple(a, b, c)
	local p, cur, prev = tonumber(a), tonumber(b), tonumber(c)
	if not p or not cur or not prev then
		return nil, nil, nil, "нужны три числа: parent current preview"
	end
	p, cur, prev = math.floor(p), math.floor(cur), math.floor(prev)
	if p < 0 or cur < 0 or prev < 0 then
		return nil, nil, nil, "ratio не может быть отрицательным"
	end
	if p + cur + prev == 0 then
		return nil, nil, nil, "сумма ratio не должна быть 0"
	end
	return p, cur, prev, nil
end

--- @param name string
--- @return integer
local function index_of(name)
	for i, n in ipairs(config.order) do
		if n == name then
			return i
		end
	end
	return 1
end

--- @param st table
--- @param name string
--- @param p integer
--- @param cur integer
--- @param prev integer
local function apply(st, name, p, cur, prev)
	st.view = name
	rt.mgr.ratio = { p, cur, prev }

	if ya.emit then
		ya.emit("app:resize", {})
		ya.emit("peek", { force = true })
	else
		ya.app_emit("resize", {})
	end

	if config.notify then
		ya.notify {
			title = "Layout",
			content = string.format("%s  [%d %d %d]", name, p, cur, prev),
			timeout = 1.5,
			level = "info",
		}
	end
end

--- Применить именованный пресет.
--- @param st table
--- @param name string
--- @return boolean
local function apply_named(st, name)
	local r = config.presets[name]
	if not r then
		return false
	end
	st.toggle_from = nil
	apply(st, name, r[1], r[2], r[3])
	return true
end

--- Переключить view ↔ предыдущий (для TZ / Tz).
--- @param st table
--- @param name string
local function toggle_named(st, name)
	local r = config.presets[name]
	if not r then
		ya.notify {
			title = "Layout",
			content = "нет view «" .. name .. "». " .. table.concat(config.order, ", "),
			timeout = 3,
			level = "warn",
		}
		return
	end

	if st.view == name then
		local back = st.toggle_from or "default"
		st.toggle_from = nil
		local br = config.presets[back]
		if br then
			apply(st, back, br[1], br[2], br[3])
		else
			apply_named(st, "default")
		end
		return
	end

	st.toggle_from = (st.view and config.presets[st.view]) and st.view or "default"
	apply(st, name, r[1], r[2], r[3])
end

--- @param _ any
--- @param opts? { presets?: table<string, integer[]>, order?: string[], notify?: boolean }
local function setup(_, opts)
	opts = opts or {}

	if type(opts.presets) == "table" then
		for k, v in pairs(opts.presets) do
			if type(v) == "table" and #v >= 3 then
				config.presets[k] = {
					tonumber(v[1]) or 0,
					tonumber(v[2]) or 0,
					tonumber(v[3]) or 0,
				}
			end
		end
	end

	if type(opts.order) == "table" and #opts.order > 0 then
		config.order = opts.order
	end

	if opts.notify ~= nil then
		config.notify = opts.notify and true or false
	end
end

--- next | prev | reset | toggle <name> | <name> | <p> <c> <pr>
--- @param st table
--- @param job table|{args: string[]}|string
local function entry(st, job)
	job = type(job) == "string" and { args = { job } } or (job or {})
	local args = job.args or {}
	local cmd = args[1]

	if not cmd or cmd == "" then
		ya.notify {
			title = "Layout",
			content = "views: " .. table.concat(config.order, ", "),
			timeout = 3,
			level = "info",
		}
		return
	end

	if cmd == "toggle" then
		local name = args[2]
		if not name then
			ya.notify { title = "Layout", content = "toggle <name>", timeout = 3, level = "warn" }
			return
		end
		toggle_named(st, name)
		return
	end

	-- Короткий синтаксис: focus! / list! = toggle
	local bang = cmd:match("^(.+)!$")
	if bang then
		toggle_named(st, bang)
		return
	end

	if cmd == "next" or cmd == "prev" then
		st.toggle_from = nil
		local i = index_of(st.view or "default")
		if cmd == "next" then
			i = i % #config.order + 1
		else
			i = (i - 2) % #config.order + 1
		end
		apply_named(st, config.order[i])
		return
	end

	if cmd == "reset" then
		st.toggle_from = nil
		apply_named(st, "default")
		return
	end

	if tonumber(cmd) and args[2] and args[3] then
		local p, cur, prev, err = parse_triple(cmd, args[2], args[3])
		if err then
			ya.notify { title = "Layout", content = err, timeout = 3, level = "error" }
			return
		end
		st.toggle_from = nil
		apply(st, string.format("%d:%d:%d", p, cur, prev), p, cur, prev)
		return
	end

	if not apply_named(st, cmd) then
		ya.notify {
			title = "Layout",
			content = "нет view «" .. cmd .. "». " .. table.concat(config.order, ", "),
			timeout = 3,
			level = "warn",
		}
	end
end

return { entry = entry, setup = setup }
