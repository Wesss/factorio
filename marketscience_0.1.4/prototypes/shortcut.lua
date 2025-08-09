data:extend({{
    type = "shortcut",
    name = "toggle-orders",
    order = "z[orders]",
    action = "lua",
    toggleable = true,
    style = "green",
    icon = {
        filename = "__base__/graphics/icons/shortcut-toolbar/mip/new-blueprint-book-x32-white.png",
        priority = "extra-high-no-scale",
        size = 32,
        scale = 0.5,
        mipmap_count = 2,
        flags = {"gui-icon"}
    },
    small_icon = {
        filename = "__base__/graphics/icons/shortcut-toolbar/mip/new-blueprint-book-x24.png",
        priority = "extra-high-no-scale",
        size = 24,
        scale = 0.5,
        mipmap_count = 2,
        flags = {"gui-icon"}
    },
    disabled_small_icon = {
        filename = "__base__/graphics/icons/shortcut-toolbar/mip/new-blueprint-book-x24-white.png",
        priority = "extra-high-no-scale",
        size = 24,
        scale = 0.5,
        mipmap_count = 2,
        flags = {"gui-icon"}
    }
}})
