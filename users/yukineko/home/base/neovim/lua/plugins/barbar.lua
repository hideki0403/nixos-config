return {
    'romgrk/barbar.nvim',
    lazy = false,
    dependencies = {
        'lewis6991/gitsigns.nvim',
        'nvim-tree/nvim-web-devicons',
    },
    opts = {
        options = {
            theme = "auto",
            section_separators = "",
            component_separators = "",
            icons_enabled = true,
        },
        sections = {
            lualine_a = { "mode" },
            lualine_b = { "branch", "diff" },
            lualine_x = { "location" },
            lualine_y = { "encoding", "fileformat", "filetype" },
            lualine_z = { "progress" },
        },
        inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = { { "filename", path = 2 } },
            lualine_x = { "location" },
            lualine_y = {},
            lualine_z = {},
        },
        tabline = {},
        extensions = {},
    },
    init = function() vim.g.barbar_auto_setup = false end,
}
