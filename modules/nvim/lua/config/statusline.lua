require("lualine").setup {
    options = {
        icons_enabled = false,
        theme = "horizon",
        component_separators = "",
        section_separators = "",
        disabled_filetypes = {}
    },
    sections = {
        lualine_a = {"mode"},
        lualine_b = {
            "branch",
            {
                "diff",
                colored = true,
                color_added = "#66cccc",
                color_modified = "#ffcc66",
                color_removed = "#f2777a",
                symbols = {added = "+", modified = "~", removed = "-"}
            }
        },
        lualine_c = {"filename"},
        lualine_x = {"encoding", "filetype"},
        lualine_y = {"progress"},
        lualine_z = {"location"}
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {"filename"},
        lualine_x = {"location"},
        lualine_y = {},
        lualine_z = {}
    },
    tabline = {},
    extensions = {}
}
