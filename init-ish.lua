-- 경로: ~/.config/nvim/init.lua
-- ==========================================================================
-- 1. 네오빔 기본 설정
-- ==========================================================================
vim.g.mapleader = " "           -- 리더키(스페이스바) 설정을 최상단으로 이동 (필수)

vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.mouse = "a"             -- 마우스 조작 활성화

-- 시스템 클립보드 연동 (iSH 호환용 기본 설정)
vim.opt.clipboard = "unnamedplus"

-- ==========================================================================
-- 2. lazy.nvim 자동 설치 (구버전 Neovim 호환형 경로 결합식 적용)
-- ==========================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

local uv = vim.uv or vim.loop
if not uv.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- ==========================================================================
-- 3. 플러그인 설정
-- ==========================================================================
require("lazy").setup({

    -- GitHub 다크 테마 플러그인 (VS Code 스타일)
    {
        "projekt0n/github-nvim-theme",
        name = "github-theme",
        lazy = false,
        priority = 1000,
        config = function()
            require("github-theme").setup({
                options = {
                    transparent = false,
                    styles = {
                        comments = "italic",
                        keywords = "bold",
                    },
                },
            })
            vim.cmd("colorscheme github_dark_high_contrast")
        end,
    },

    -- 작업 상황 자동 저장 및 복원 (Auto Session)
    {
        "rmagatti/auto-session",
        lazy = false,
        config = function()
            require("auto-session").setup({
                log_level = "error",
                auto_restore_enabled = true,
                auto_save_enabled = true,
                auto_session_enable_last_session = false,
                pre_save_cmds = { "Neotree close" },
                post_restore_cmds = { "Neotree show" },
            })
        end,
    },

    -- [VS Code 구성 1] 좌측 사이드바 폴더 트리 플러그인
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
        },
        config = function()
            require("neo-tree").setup({
                close_if_last_window = true,
                default_component_configs = {
                    icon = {
                        folder_closed = "[+]",
                        folder_open = "[-]",
                        folder_empty = "[ ]",
                        default = "-",
                    },
                    git_status = {
                        symbols = {
                            added     = "A",
                            modified  = "M",
                            deleted   = "D",
                            renamed   = "R",
                            untracked = "?",
                            ignored   = "I",
                            unstaged  = "U",
                            staged    = "S",
                            conflict  = "C",
                        },
                    },
                },
                window = {
                    width = 30,
                    mappings = {
                        ["<space>"] = "none",
                        ["<RightMouse>"] = function()
                            local keys = vim.api.nvim_replace_termcodes("<LeftMouse>m", true, false, true)
                            vim.api.nvim_feedkeys(keys, "m", true)
                        end,
                        ["<F2>"] = "rename",
                        ["<M-r>"] = "refresh",
                    },
                },
                filesystem = {
                    follow_current_file = { enabled = true },
                    filtered_items = { visible = true },
                    bind_to_cwd = false,
                },
            })
        end,
    },

    -- [VS Code 구성 2] 상단 파일 탭 전환 플러그인 (Bufferline)
    {
        "akinsho/bufferline.nvim",
        version = "*",
        config = function()
            require("bufferline").setup({
                options = {
                    mode = "buffers",
                    numbers = "none",
                    show_buffer_icons = false,
                    show_buffer_close_icons = false,
                    show_close_icon = false,
                    close_command = "bdelete! %d",
                    right_mouse_command = "bdelete! %d",
                    separator_style = "thin",
                    offsets = {
                        {
                            filetype = "neo-tree",
                            text = "EXPLORER",
                            text_align = "center",
                            separator = true,
                        },
                    },
                },
                highlights = {
                    buffer_selected = {
                        fg = "#ffffff",
                        bg = "#1e40af",
                        bold = true,
                    },
                    indicator_selected = {
                        fg = "#3b82f6",
                        bg = "#1e40af",
                    },
                    modified_selected = {
                        fg = "#f59e0b",
                        bg = "#1e40af",
                    },
                    separator_selected = {
                        fg = "#1e40af",
                        bg = "#1e40af",
                    },
                    background = {
                        fg = "#6b7280",
                        bg = "#111827",
                    },
                    buffer_visible = {
                        fg = "#a3a3a3",
                        bg = "#1f2937",
                    },
                },
            })
        end,
    },

}, {
    ui = {
        show = false,
    },
})

-- ==========================================================================
-- 4. 네오빔 시작 시 파일 트리 자동 실행
-- ==========================================================================
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        if vim.fn.argc() == 0 then
            vim.cmd("Neotree show")
        end
    end,
})

-- ==========================================================================
-- 5. 단축키 매핑
-- ==========================================================================
-- 스페이스바 + e : 좌측 폴더 트리 사이드바 토글
vim.keymap.set("n", "<leader>e", ":Neotree toggle left<CR>", { silent = true })

-- Shift + h/l : 왼쪽 / 오른쪽 파일 탭으로 이동
vim.keymap.set("n", "H", ":BufferLineCyclePrev<CR>", { silent = true })
vim.keymap.set("n", "L", ":BufferLineCycleNext<CR>", { silent = true })

-- Alt + h / Alt + l : 파일 탭 위치 이동
vim.keymap.set("n", "<M-h>", ":BufferLineMovePrev<CR>", { silent = true })
vim.keymap.set("n", "<M-l>", ":BufferLineMoveNext<CR>", { silent = true })

-- 안전한 탭 닫기
vim.keymap.set("n", "<leader>q", function()
    local bd = function(buf)
        buf = buf or vim.api.nvim_get_current_buf()
        local buffers = vim.tbl_filter(function(b)
            return vim.api.nvim_buf_is_valid(b)
                and vim.bo[b].buflisted
                and vim.bo[b].buftype == ""
        end, vim.api.nvim_list_bufs())

        if #buffers <= 1 then
            vim.cmd("enew")
            vim.cmd("bdelete! " .. buf)
        else
            vim.cmd("BufferLineCycleNext")
            vim.cmd("bdelete! " .. buf)
        end
    end

    if vim.bo.filetype == "neo-tree" then
        vim.cmd("wincmd l")
    end

    bd()
end, { silent = true })

-- Tab 키로 사이드바 포커스 전환
vim.keymap.set("n", "<Tab>", function()
    if vim.bo.filetype == "neo-tree" then
        vim.cmd("wincmd p")
    else
        local neo_tree_win = nil
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == "neo-tree" then
                neo_tree_win = win
                break
            end
        end

        if neo_tree_win then
            vim.api.nvim_set_current_win(neo_tree_win)
        else
            vim.cmd("Neotree focus left")
        end
    end
end, { silent = true })
