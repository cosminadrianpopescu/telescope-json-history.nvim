# telescope-json-history.nvim

History implementation with json backend. 

This is a [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
extension which is going to save the prompt history based on the current
picker. If `include_cwd` is set to true, then it will also take into
consideration the current folder where telescope was invoked.

I've started from [this
point](https://github.com/nvim-telescope/telescope-smart-history.nvim) and
ended up with this small extension.

## Setup

It will be configured with the same keys as the normal history configuration.

```lua
telescope.setup {
    defaults = {
        history = {
            -- path: optional, the place where to save the history
            path = os.getenv('HOME') .. '/.cache/nvim/telescope_history',
            -- include_cwd, options. If true, then the history will be
            -- saved / retrieved depending also on the directory in which
            -- telescope promnt was invoked
            include_cwd = true,
            -- limit, optional the number of items to save in each history
            -- context
            limit = 100,
        }
    }
}


require('telescope').load_extension('json_history')
```
