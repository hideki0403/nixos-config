return {
    'nvim-lualine/lualine.nvim',
    lazy = false,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
        options = {
            theme = 'auto',
            globalstatus = true,
            -- disabled_filetypes = { statusline = { 'dashboard', 'alpha' } },
        },
        sections = {
            lualine_a = { 'mode' },
            lualine_b = { 'branch', 'diff' },
            lualine_c = { 'diagnostics' },
            lualine_x = { 'progress' },
            lualine_y = { 'encoding', 'fileformat', 'filetype' },
            lualine_z = { 'location' },
        },
    }
}
