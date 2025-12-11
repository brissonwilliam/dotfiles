-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"


-- KEYBINDS MAP
local function goErrCheck()
    vim.api.nvim_feedkeys("iif err != nil { return err }<ESC>", 'n', false)
end
vim.keymap.set("n", "<space>e", goErrCheck, { desc = "Insert Go error check" })

-- SYSTEM CLIPBOARD
-- osc52 sends an ANSI sequence that can be forwarded all the way to the terminal
-- emulator process  instead of directly trying to copy to the host desktop's clipboard
-- In other words, it makes it so we can copy/paste over ssh rather than on the host wayland clipboard
-- (neovim -> tmux -> ssh > ghostty)
vim.g.clipboard = 'osc52'

-- Setup lazy.nvim
-- lazy mean the plugin is loaded once a plugin requires it only
-- you can use the VeryLazy event for things that can
-- load later and are not important for the initial UI

local plugins = {
    -- ############ NVIM-LSPCONFIG ##################
    -- nvim-lspconfig is to load client configs to provide to neovim based on installed lsp-s
    {
        'neovim/nvim-lspconfig',
    },
    -- ############ NVIM-CMP ##################
    -- cmp is the window display for lsp
    {
        "hrsh7th/nvim-cmp",
        version = false,
        -- event = "InsertEnter",
        -- nvim lsp setup is not done async, so load right away for cmp to be available
        lazy = false,
        config = function()
            local cmp = require "cmp"
            cmp.setup({
                -- snippet is greyed out suggestion inline
                snippet = {
                    -- REQUIRED - you must specify a snippet engine
                    expand = function(args)
                        require('luasnip').lsp_expand(args.body)
                    end,
                },
                preselect = cmp.PreselectMode.None, -- no default preset
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                mapping = cmp.mapping.preset.insert({
                    ['<TAB>'] = cmp.mapping.select_next_item(),
                    ['<S-TAB>'] = cmp.mapping.select_prev_item(),
                    ['<C-j>'] = cmp.mapping.select_next_item(),
                    ['<C-k>'] = cmp.mapping.select_prev_item(),
                    ['<C-d>'] = cmp.mapping.select_next_item({ count = 10 }),
                    ['<C-u>'] = cmp.mapping.select_prev_item({ count = 10 }),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['qq'] = cmp.mapping.abort(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                }),

                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                    { name = 'buffer' },
                }),
                -- source index priority weight for results
                sorting = { priority_weight = 2 },
            })

            cmp.setup.cmdline({ '/', '?' }, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = 'buffer' }
                }
            })
            cmp.setup.cmdline(':', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = 'nvim_lua' },
                    { name = 'cmdline' },
                },
            })
        end,
        dependencies = {
            "neovim/nvim-lspconfig",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            -- luasnip is the snippet window that provides context about an autocomplete entry
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
            -- variable, func, const symbols in floating window
            'onsails/lspkind.nvim',
        },
    },
    -- ############ HARPOON ##################
    -- nvim-tree provides a tree-like pane to explore, edit, add or delete files
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim",
        },
        config = function()
            local harpoon = require("harpoon")
            -- REQUIRED
            harpoon:setup()

            -- telescope extension
            local conf = require("telescope.config").values
            local function toggle_telescope(harpoon_files)
                local file_paths = {}
                for _, item in ipairs(harpoon_files.items) do
                    table.insert(file_paths, item.value)
                end

                require("telescope.pickers").new({}, {
                    prompt_title = "Harpoon",
                    finder = require("telescope.finders").new_table({
                        results = file_paths,
                    }),
                    previewer = conf.file_previewer({}),
                    sorter = conf.generic_sorter({}),
                }):find()
            end
            -- vim.keymap.set("n", "<Space>h", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,{ desc = "Open harpoon window" })
            vim.keymap.set("n", "<Space>h", function() toggle_telescope(harpoon:list()) end,
                { desc = "Open harpoon window" })

            vim.keymap.set("n", "<Space>d", function() harpoon:list():remove() end)
            vim.keymap.set("n", "<Space>a", function() harpoon:list():add() end)
            vim.keymap.set("n", "<Space>1", function() harpoon:list():select(1) end)
            vim.keymap.set("n", "<Space>2", function() harpoon:list():select(2) end)
            vim.keymap.set("n", "<Space>3", function() harpoon:list():select(3) end)
            vim.keymap.set("n", "<Space>4", function() harpoon:list():select(4) end)
            vim.keymap.set("n", "<Space>5", function() harpoon:list():select(5) end)

            vim.keymap.set("n", "<Space>n", function() harpoon:list():prev() end)
            vim.keymap.set("n", "<Space>b", function() harpoon:list():next() end)
        end,
    },
    -- ############ NVIM-TREE ##################
    -- nvim-tree provides a tree-like pane to explore, edit, add or delete files
    {
        "nvim-tree/nvim-tree.lua",
        lazy = false,
        version = "*",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("nvim-tree").setup({
                on_attach = function(bufnr)
                    local api = require('nvim-tree.api')
                    local function opts(desc)
                        return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
                    end

                    vim.keymap.set('n', 't', api.node.open.tab, opts('Open: New Tab'))
                    vim.keymap.set('n', 'v', api.node.open.vertical, opts('Open: Vertical Split'))
                    vim.keymap.set('n', 's', api.node.open.horizontal, opts('Open: Horizontal Split'))
                    vim.keymap.set('n', '<BS>', api.node.navigate.parent_close, opts('Close Directory'))
                    vim.keymap.set('n', '<CR>', api.node.open.edit, opts('Open'))
                    vim.keymap.set('n', '<Tab>', api.node.open.preview, opts('Open Preview'))
                    vim.keymap.set('n', '>', api.node.navigate.sibling.next, opts('Next Sibling'))
                    vim.keymap.set('n', '<', api.node.navigate.sibling.prev, opts('Previous Sibling'))
                    vim.keymap.set('n', '-', api.tree.change_root_to_parent, opts('Up'))
                    vim.keymap.set('n', 'a', api.fs.create, opts('Create File Or Directory'))
                    vim.keymap.set('n', 'y', api.fs.copy.node, opts('Copy'))
                    vim.keymap.set('n', 'zk', api.node.navigate.git.prev, opts('Prev Git'))
                    vim.keymap.set('n', 'zj', api.node.navigate.git.next, opts('Next Git'))
                    vim.keymap.set('n', 'd', api.fs.remove, opts('Delete'))
                    vim.keymap.set('n', 'E', api.tree.expand_all, opts('Expand All'))
                    vim.keymap.set('n', 'F', api.live_filter.clear, opts('Live Filter: Clear'))
                    vim.keymap.set('n', 'f', api.live_filter.start, opts('Live Filter: Start'))
                    vim.keymap.set('n', 'g?', api.tree.toggle_help, opts('Help'))
                    vim.keymap.set('n', '<Space>Y', api.fs.copy.absolute_path, opts('Copy Absolute Path'))
                    vim.keymap.set('n', '<Space>y', api.fs.copy.filename, opts('Copy Name'))
                    -- vim.keymap.set('n', 'Y',       api.fs.copy.relative_path,           opts('Copy Relative Path'))
                    vim.keymap.set('n', 'H', api.tree.toggle_hidden_filter, opts('Toggle Filter: Dotfiles'))
                    vim.keymap.set('n', 'I', api.tree.toggle_gitignore_filter, opts('Toggle Filter: Git Ignore'))
                    vim.keymap.set('n', 'm', api.marks.toggle, opts('Toggle Bookmark'))
                    vim.keymap.set('n', 'o', api.node.open.no_window_picker, opts('Open'))
                    vim.keymap.set('n', 'p', api.fs.paste, opts('Paste'))
                    vim.keymap.set('n', 'P', api.node.navigate.parent, opts('Parent Directory'))
                    vim.keymap.set('n', 'q', api.tree.close, opts('Close'))
                    vim.keymap.set('n', 'r', api.fs.rename, opts('Rename'))
                    vim.keymap.set('n', 'R', api.fs.rename_full, opts('Rename: Full Path'))
                    vim.keymap.set('n', '<C-r>', api.tree.reload, opts('Refresh'))
                    vim.keymap.set('n', '<C-s>', api.tree.search_node, opts('Search'))
                    vim.keymap.set('n', 'W', api.tree.collapse_all, opts('Collapse'))
                    vim.keymap.set('n', 'x', api.fs.cut, opts('Cut'))
                end,
                filters = {
                    enable = true,
                    git_ignored = false,
                    dotfiles = false,
                    git_clean = false,
                    no_buffer = false,
                    no_bookmark = false,
                    custom = {},
                    exclude = {},
                },
                actions = {
                    change_dir = { enable = false }
                },
            })
        end,
    },

    -- ############ STATUS LINE POWERLINE ##################
    -- lightline powerline at bottom
    {
        'nvim-lualine/lualine.nvim',
        config = function()
            local function currentbuff()
                return '#' .. vim.api.nvim_get_current_buf()
            end
            local function relpath()
                return vim.fn.expand("%")
            end
            require("lualine").setup({
                -- options = {
                -- component_separators = { left = '', right = '' },
                -- section_separators = { left = '', right = '' },
                -- },
                sections = {
                    lualine_a = { 'mode' },
                    lualine_b = { 'branch' },
                    lualine_c = { { relpath, color = { fg = '#e0e0da' } } },
                    lualine_x = { 'encoding', { 'filetype', icons_enabled = false } },
                    lualine_y = { 'progress' },
                    lualine_z = { { currentbuff } }
                },
            })
        end,
        dependencies = { 'nvim-tree/nvim-web-devicons' }
    },
    -- ############ LSP_SIGNATURE ##################
    -- lsp function signature
    {
        "ray-x/lsp_signature.nvim",
        event = "InsertEnter",
        opts = {
            bind = true,
            handler_opts = {
                border = "rounded"
            }
        },
    },

    -- ############ TELESCOPE ##################
    -- Telescope for fuzzy finding, rigrep text search and ui select action
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            'nvim-lua/plenary.nvim',
            'nvim-telescope/telescope-live-grep-args.nvim',
        },
        config = function()
            local telescope = require('telescope')
            local action = require("telescope.actions")
            local action_state = require("telescope.actions.state")

            telescope.setup({
                defaults = {
                    mappings = {
                        i = {
                            ["<Esc>"] = action.close,
                            ["<C-j>"] = action.move_selection_next,
                            ["<C-k>"] = action.move_selection_previous,
                            ["<C-c>"] = action.select_tab,
                            ["<C-y>"] = function(prompt_bufnr)
                                local entry = action_state.get_selected_entry()
                                if entry and entry.value then
                                    vim.fn.setreg("+", entry.value)
                                end
                            end,
                        },
                    },
                    path_display = { "truncate" },
                    layout_strategy = "horizontal",
                    file_ignore_patterns = { ".git/" },
                    layout_config = {
                        center = { width = 0.666, height = 0.4, preview_cutoff = 30, prompt_position = "top", mirror = true },
                        cursor = { width = 0.7, height = 0.3, preview_cutoff = 30, preview_width = 90 },
                        horizontal = { width = 0.9, height = 0.9, preview_cutoff = 120, prompt_position = "top" },
                    },
                },
                pickers = {
                    --find_files = require('telescope').get_dropdown({layout_config = { width = 0.66, height = 0.66, anchor="center", preview_cutoff= 50, prompt_position="top", mirror = true }}),
                    find_files = { layout_strategy = "center", hidden = true },
                    git_status = { layout_strategy = "center" },
                    buffers = { layout_strategy = "center" },
                    lsp_references = { layout_strategy = "horizontal" },
                    lsp_implementations = { layout_strategy = "horizontal" },
                    lsp_type_defintions = { layout_strategy = "horizontal" },
                },
            })

            -- telescope.load_extension("smart_history")
            -- ui-select is for refactor action selection
            -- args to specify file types and paths on regex searches
            telescope.load_extension("live_grep_args")
        end
    },

    -- ############ MASON ##################
    -- mason to pick and download lsps
    {
        "mason-org/mason.nvim",
        opts = {}
    },

    -- ############ DAP DEBUG ##################
    -- dap for debugging
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "igorlfs/nvim-dap-view",
            "theHamsta/nvim-dap-virtual-text",
        }
    },

    -- ############ AI AGENT BULLSHIT COPILOT ##################
    --{
    --    "github/copilot.vim"
    --},
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        dependencies = {
            -- { "github/copilot.vim" },                       -- or zbirenbaum/copilot.lua
            { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
        },
        build = "make tiktoken",                            -- Only on MacOS or Linux
        opts = {
            -- chat_autocomplete = false,
            mappings = {
                yank_diff = {
                    normal = '<C-y>',
                    insert = '<C-y>',
                    register = '"', -- Default register to use for yanking
                },
                accept_diff = {
                    normal = '<Space>y>',
                },
                reset = {
                    normal = '<C-l>',
                    insert = '<C-l>',
                },
            },
            window = {
                -- layout = 'float',
                width = 100,        -- Fixed width in columns
                height = 40,        -- Fixed height in rows
                border = 'rounded', -- 'single', 'double', 'rounded', 'solid'
                title = '🤖 AI Assistant',
                -- zindex = 100,       -- Ensure window stays on top
            },
            headers = {
                user = '👺 You: ',
                assistant = '🤖 Copilot: ',
                tool = '🔧 Tool: ',
            },
            separator = '━━',
            show_folds = false, -- Disable folding for cleaner look
            sticky = { "Current buffer is #buffer", "All files (glob): #glob" }
            -- auto_insert_mode = true, -- broken right now
        },
    },
    -- ############ DASHBOARD ALPHA ##################
    --
    {
        'goolord/alpha-nvim',
    },

    -- ############ VARIOUS MISC ERGO PLUGINS ##################
    {
        'machakann/vim-highlightedyank',
    },
    -- multi cursor
    {
        'mg979/vim-visual-multi',
    },
    -- git integration
    {
        'lewis6991/gitsigns.nvim',
        config = function()
            local map = vim.keymap.set
            local opts = { silent = true }
            local gs = require("gitsigns");

            map("n", "zp", function() gs.preview_hunk() end, opts)
            map("n", "zu", function() gs.reset_hunk() end, opts)
            map("n", "zj", function() require("gitsigns").nav_hunk("next") end, opts)
            map("n", "zk", function() require("gitsigns").nav_hunk("prev") end, opts)

        end
        --    opts = { sign_priority = 11 }
    },
    {
        'tpope/vim-fugitive',
        config = function ()
            local map = vim.keymap.set
            local opts = { silent = true }
            map("n", "zb", ":Git blame<CR>", opts)
            map("n", "za", ":Git add .<CR>", opts)
            map("n", "zr", ":Git reset .<CR>", opts)
            map("n", "zl", ":0GcLog<CR>", opts)
            map("n", "zdd", ":horizontal rightbelow Git diff<CR>", opts)
            map("n", "zdv", ":vertical rightbelow Git diff<CR>", opts)
            map("n", "zdt", ":tab rightbelow Git diff<CR>", opts)
            map("n", "zs", ":horizontal belowright Git<CR>", opts)
        end
    },
    -- nicer input and select visuals
    {
        'stevearc/dressing.nvim',
        opts = {
            input = {
                border = "rounded",
                relative = "editor",
                width = 60,
                win_options = {
                    winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
                },
            },
        },
    },

    -- ############ COLORSCHEMES / THEMES ##################
    -- colorschemes and themes
    { "dracula/vim",              name = "dracula" },
    { "joshdick/onedark.vim" },
    { "sainnhe/gruvbox-material" },
    { "srcery-colors/srcery-vim", name = "srcery" },
    { "jacoborus/tender.vim" },
    { "ellisonleao/gruvbox.nvim", config = true,   opts = { bold = true } },
    {
        'everviolet/nvim',
        name = 'evergarden', -- 'evergarden-winter'|'evergarden-fall'|'evergarden-spring'|'evergarden-summer'
        opts = {
            theme = {
                variant = 'fall', -- 'winter'|'fall'|'spring'|'summer'
                accent = 'green',
            },
            style = {
                tabline = { 'reverse' },
                search = { 'reverse' },
                incsearch = { 'reverse' },
            },
        }

    },
    { "scottmckendry/cyberdream.nvim" },
    {
        "rose-pine/neovim", -- rose-pine-main, rose-pine-moon, rose-pine-dawn
        name = "rose-pine",
        opts = {
            variant = "main", -- auto, main, moon, or dawn
            palette = {
                main = { pine = "#3e8fb0" }
            },
            groups = {
                border = "muted",
                link = "iris",
                panel = "surface",
            },
            styles = {
                bold = true,
                italic = true,
                transparency = false,
            },
        }
    },
    { "catppuccin/nvim",              name = "catppuccin" }, -- catppuccin-latte, catppuccin-frappe, catppuccin-macchiato, catppuccin-mocha
    {
        'AlexvZyl/nordic.nvim',
        config = function()
            require('nordic').setup({
                bold_keywords = true,
                italic_comments = true,
                reduced_blue = true,
                bright_border = true,
                telescope = {
                    -- Available styles: `classic`, `flat`.
                    style = 'classic',
                },
            })
        end
    },
    {
        "vague2k/vague.nvim",
        config = function()
            -- NOTE: you do not need to call setup if you don't want to.
            require("vague").setup({
                bold = true
            })
        end
    },
    {
        "folke/tokyonight.nvim", -- some variants available when setting colorscheme ['tokyonight-night', 'tokyonight-moon',  'tokyonight-storm', 'tokyonight-day'}
        opts = {},
    }
}

require("lazy").setup({
    spec = plugins,
    -- Configure any other settings here. See the documentation for more details.
    install = {},
    -- automatically check for plugin updates
    -- checker = { enabled = true },
})

-- ########### SET COLORSCHEME THEME ############
-- must be after lazy is loaded
vim.cmd.colorscheme('evergarden')

local alpha = {}
local alpha_ok = false

local function headerSection()
    -- more ascci arts here: https://github.com/nvimdev/dashboard-nvim/wiki/Ascii-Header-Text
    -- or use this (DOS rebel is good font, or ANSI Shadow) https://manytools.org/hacker-tools/ascii-banner
    local headerVal = {
        [[                                                   ]],
        [[ ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗]],
        [[ ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║]],
        [[ ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║]],
        [[ ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║]],
        [[ ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║]],
        [[ ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
        [[                     by the way                    ]],
        [[                                                   ]],
    }
    -- yellow
    -- vim.api.nvim_set_hl(0, "DashboardHeader", { bg = "", fg = "#E19720" })
    return {
        type = "text",
        val = headerVal,
        opts = { position = "center" },
    }
end

local function artSection()
    local art = {
        [[         ▀████▀▄▄              ▄█ ]],
        [[           █▀    ▀▀▄▄▄▄▄    ▄▄▀▀█ ]],
        [[   ▄        █          ▀▀▀▀▄  ▄▀  ]],
        [[  ▄▀ ▀▄      ▀▄              ▀▄▀  ]],
        [[ ▄▀    █     █▀   ▄█▀▄      ▄█    ]],
        [[ ▀▄     ▀▄  █     ▀██▀     ██▄█   ]],
        [[  ▀▄    ▄▀ █   ▄██▄   ▄  ▄  ▀▀ █  ]],
        [[   █  ▄▀  █    ▀██▀    ▀▀ ▀▀  ▄▀  ]],
        [[  █   █  █      ▄▄           ▄▀   ]],
    }
    -- yellow
    -- vim.api.nvim_set_hl(0, "Pikachu", {bg="#E19720", fg="#010004"})
    -- white
    vim.api.nvim_set_hl(0, "Pikachu", { bg = "#efebe5", fg = "#010004" })

    -- for some reason when centered the whole left section of screen is highlighted with bg
    -- so we manually build the highlights here
    local highlights = {}
    for i = 1, #art do
        table.insert(highlights, { { "Pikachu", 0, -1 } })
    end

    return {
        type = "text",
        val = art,
        opts = { position = "center", hl = highlights },
    }
end

local function displayButton(sc, txt)
    local opts = {
        position = "center",
        shortcut = sc,
        cursor = 3,
        width = 50,
        align_shortcut = "right",
        hl_shortcut = "Keyword",
    }
    local function onPress()
        vim.api.nvim_feedkeys(sc, "t", false)
    end

    return {
        type = "button",
        val = txt,
        on_press = onPress,
        opts = opts,
    }
end

local function buttonSection()
    return {
        type = "group",
        val = {
            displayButton("<C-n>", "  Find file"),
            displayButton("gt", "󰄗  New tab"),
            displayButton("<C-s>", "  Find text"),
            displayButton("<C-t>", "  Toggle file tree"),
            displayButton("zn", "  Git diff files"),
            displayButton("q", "󰩈  Quit Neovim"),
        },
        opts = { spacing = 1 },
    }
end

local weekdaySection = {
    type = "text",
    val = os.date("Today is %A"),
    opts = { position = "center", hl = "Function" },
}
local dateSection = {
    type = "text",
    val = os.date("  %d-%m-%Y"),
    opts = { position = "center", hl = "Function" },
}

math.randomseed(os.time() * os.clock() * 100)
local function randomQuote()
    local quotes = {
        "woo!",
        "meow 🐈",
        "AS TU VU LES QUENOUILLES!!!?",
        "La vie, la vie c'est triste non?",
        "Magical carpet ride 🪄",
        "You don't have to hold on to a star 🌟",
        "AAAAAAAAAAAAAAAAHHHHHHHH",
        "GHUHHAAAAAAAARRRRRRRR",
        "(^_^)",
        "🦭🐈🦕ʳᵃʷʳʳ🦧🚀💻",
    }
    local length = #quotes
    local randomIndex = math.random(length)
    return { quotes[randomIndex] }
end

local function quoteSection()
    return {
        type = "text",
        -- val = {"Don't stop until you are proud"},
        val = randomQuote(),
        opts = { position = "center", hl = "Macro" },
    }
end

local function versionSection()
    local version = vim.version()
    local versionPrint = "v" .. version.major .. "." .. version.minor .. "." .. version.patch
    return {
        type = "text",
        val = versionPrint,
        opts = { position = "center", hl = "Red" },
    }
end

local function pad(n)
    return { type = "padding", val = n }
end

function DASHBOARD()
    if not alpha_ok then
        return
    end

    alpha.setup({
        layout = {
            pad(1),
            headerSection(),
            artSection(),
            pad(2),
            buttonSection(),
            pad(2),
            weekdaySection,
            pad(1),
            quoteSection(),
            pad(1),
            versionSection(),
        },
        position = "center",
        opts = {
            keymap = { press = nil },
        },
    })
end

alpha_ok, alpha = pcall(require, "alpha")
DASHBOARD()


-- #####
-- NVIM NEOVIM vim configs
--
--
-- override window float size for lsp
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    -- https://neovim.io/doc/user/options.html#'winborder'
    -- https://neovim.io/doc/user/lsp.html#vim.lsp.util.open_floating_preview.Opts
    opts = opts or {}
    opts.border = opts.border or 'rounded'
    opts.anchor_bias = opts.anchor_bias or 'below'
    opts.max_width = opts.max_width or 100
    return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

-- INLAY HINTS LSP
local function enableInlayHints()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end
vim.keymap.set("n", '<Space>i', enableInlayHints)

-- codeAction LSP filter and binding
local function filterLsp(codeAction)
    if codeAction.kind == "source.doc" then
        return false
    end
    if codeAction.kind == "gopls.doc.features" then
        return false
    end
    return true
end
local function codeAction()
    vim.lsp.buf.code_action({ filter = filterLsp })
end
vim.keymap.set('n', 'ra', codeAction, { noremap = true })

local function refactorWrite()
    vim.lsp.buf.format()
    vim.cmd.write()
end
vim.keymap.set('n', 'rw', refactorWrite, { noremap = true })


-- hook this into every lsp config
-- cmp is the floating window to show lsp suggestions
local capabilities = require('cmp_nvim_lsp').default_capabilities()

vim.lsp.config('*', { capabilities = capabilities })

vim.lsp.config('gopls', {
    settings = {
        gopls = {
            staticcheck = true,
            semanticTokens = true,
            semanticTokenTypes = {
                string = false,
            },
            codelenses = { test = true, references = false }
        },
    }
})

local mason_packages = os.getenv("HOME") .. "/.local/share/nvim/mason/packages"

-- tsserver js vue lsp setup
-- since volar 2.0, typescript is not supported. We need to plug volar into ts_ls
local vue_plugin = {
    name = '@vue/typescript-plugin',
    location = mason_packages .. "/vue-language-server/node_modules/@vue/language-server",
    languages = { 'vue' },
    configNamespace = 'typescript',
}

vim.lsp.config('ts_ls', {
    capabilities = capabilities,
    init_options = {
        plugins = {
            vue_plugin,
        },
        hostInfo = "neovim",
    },
    filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx", "vue" }
})

-- java lsp config
local home = os.getenv("HOME")
local java_workspace_dir = home .. "/.local/share/eclipse/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
vim.lsp.config('jdtls', {
    cmd = {
        "jdtls", "-data", java_workspace_dir,
        "--jvm-arg=" .. string.format("-javaagent:%s", vim.fn.expand "$MASON/share/jdtls/lombok.jar"),
    },
})

-- enable the following lsp for usage based on config (defaults defined by lspconfig, no '*' or earlier calls above)
vim.lsp.enable({
    'gopls',
    'ts_ls',
    'vue_ls',
    'lua_ls',
    'rust_analyzer',
    'pyright',
    'clangd',
    'glsl_analyzer',
    'jdtls',
    'bashls',
});


-- #### LSP SIGNS
vim.diagnostic.config({
    underline = true,
    update_in_insert = true,
    virtual_lines = false,
    virtual_text = {
        spacing = 4,
        -- source is to show the "nature" of the error. For example 'syntax' is a source value
        -- source = "if_many",
        source = false,
        prefix = "●",
    },
    severity_sort = true,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = '✘',
            [vim.diagnostic.severity.WARN] = '⚑',
            [vim.diagnostic.severity.HINT] = '▲',
            [vim.diagnostic.severity.INFO] = '»',
        },
    },
})

-- ### DAP config
local dap = require('dap')

-- DAP go debug delve
dap.adapters.delve = {
    type = 'server',
    port = '${port}',
    executable = {
        command = 'dlv',
        args = { 'dap', '-l', '127.0.0.1:${port}', '--log', '--log-output="dap"' },
    }
}
dap.adapters.delveattach = {
    type = "server",
    host = "127.0.0.1",
    port = 38697,
}

local function get_arguments()
    return coroutine.create(function(dap_run_co)
        local args = {}
        vim.ui.input({ prompt = "Args: " }, function(input)
            args = vim.split(input or "", " ")
            coroutine.resume(dap_run_co, args)
        end)
    end)
end

-- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
dap.configurations.go = {
    {
        type = "delve",
        name = "Launch debug with args",
        request = "launch",
        mode = "debug",
        program = "./",
        args = get_arguments,
    },
    {
        type = "delve",
        name = "Debug test file", -- configuration for debugging test files
        request = "launch",
        mode = "test",
        program = "./${relativeFileDirname}"
    },
    -- works with go.mod packages and sub packages
    {
        type = "delve",
        name = "Debug test all (go.mod)",
        request = "launch",
        mode = "test",
        program = "./"
    }
}
