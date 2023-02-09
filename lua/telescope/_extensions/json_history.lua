local histories = require "telescope.actions.history"

local include_cwd = false

local file_exists = function(name)
    local f = io.open(name, "rb")
    if f then
        f:close()
    end

    return f ~= nil
end

local init_file = function(name)
    if file_exists(name) then
        return
    end

    local f = io.open(name, "w")
    f:write("{}")
    f:close()
end

local read_db = function(name)
    init_file(name)
    local f = io.open(name, "r")
    local txt = f:read("*a")
    f:close()
    return vim.json.decode(txt)
end

local save_db = function(name, json)
    init_file(name)
    local f = io.open(name, "w")
    f:write(vim.json.encode(json))
    f:close()
end

local json_history = function()
    local ensure_content = function(self, picker, cwd)
        if self._current_tbl then
            return
        end
        local current_picker = self.data[picker]
        if current_picker == nil then
            current_picker = {}
        end
        if include_cwd then
            self._current_tbl = current_picker[cwd]
            if self._current_tbl == nil then
                self._current_tbl = {}
            end
            current_picker[cwd] = self._current_tbl
        else
            self._current_tbl = current_picker
        end
        self.data[picker] = current_picker

        self.content = {}
        for k, v in ipairs(self._current_tbl) do
            self.content[k] = v
        end
        self.index = #self.content + 1
    end

    return histories.new {
        init = function(obj)
            init_file(obj.path)
            obj.data = read_db(obj.path)
            obj._current_tbl = nil
        end,
        reset = function(self)
            self._current_tbl = nil
            self.content = {}
            self.index = 1
        end,
        append = function(self, line, picker, no_reset)
            local title = picker.prompt_title
            local cwd = picker.cwd or vim.loop.cwd()

            if line ~= "" then
                ensure_content(self, title, cwd)
                if self.content[#self.content] ~= line then
                    table.insert(self.content, line)

                    local len = #self.content
                    if self.limit and len > self.limit then
                        local diff = len - self.limit
                        local ids = {}
                        for i = 1, diff do
                            if self._current_tbl then
                                table.insert(ids, self._current_tbl[i].id)
                            end
                        end
                        table.remove(self._current_tbl, 1)
                    end
                    table.insert(self._current_tbl, line)
                    save_db(self.path, self.data)
                end
            end
            if not no_reset then
                self:reset()
            end
        end,
        pre_get = function(self, _, picker)
            local cwd = picker.cwd or vim.loop.cwd()
            ensure_content(self, picker.prompt_title, cwd)
        end,
    }
end

return require("telescope").register_extension {
    setup = function(_, config)
        if config.history ~= false then
            include_cwd = config.history.include_cwd or false
            config.history.handler = function()
                return json_history()
            end
        end
    end,
    exports = {
        json_history = function()
            return json_history()
        end,
    },
}
