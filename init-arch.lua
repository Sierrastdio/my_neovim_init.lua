-- ==========================================================================
-- 1. 네오빔 기본 설정
-- ==========================================================================
vim.g.mapleader = " "              -- 리더키(스페이스바) 설정

vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.mouse = "a"                -- 마우스 조작 활성화

-- ==========================================================================
-- 2. lazy.nvim 자동 설치 (윈도우 경로 호환성 보정 완료)
-- ==========================================================================
local lazypath = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy", "lazy.nvim")

if not vim.uv.fs_stat(lazypath) then
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
        end
    },

    -- 구문 강조 엔진 (Treesitter 최신 단독 접근 규격)
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").setup({
                ensure_installed = { "c", "lua", "vim", "vimdoc", "python" },
                highlight = { enable = true },
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
                        }
                    }
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
                    }
                },
                filesystem = {
                    follow_current_file = { enabled = true },
                    filtered_items = { visible = true },
                    bind_to_cwd = false,
                }
            })
        end
    },

    -- [VS Code 구성 2] 상단 파일 탭 전환 플러그인 (Bufferline 검증 규격)
    {
        "akinsho/bufferline.nvim",
        version = "*",
        dependencies = { "projekt0n/github-nvim-theme" },
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
                    }
                }
            })
        end,
    },

}, {
    ui = {
        show = false,
    },
})

-- ==========================================================================
-- 4. 네오빔 시작 시 파일 트리 강제 실행 자동화 스크립트
-- ==========================================================================
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        if vim.fn.argc() == 0 then
            vim.cmd("Neotree show")
        end
    end
})

-- ==========================================================================
-- 5. 키맵핑 설정 (원래 설정 보존 + H/L 위치 전환 적용)
-- ==========================================================================

-- 입력 모드 탈출: jk 및 kj 모두 Esc로 작동
vim.keymap.set("i", "jk", "<Esc>", { silent = true })
vim.keymap.set("i", "kj", "<Esc>", { silent = true })

-- 노멀 모드에서 ';' 만 눌러도 곧바로 명령어 입력(':') 창이 열리도록 설정
vim.keymap.set("n", ";", ":", { silent = false })

-- 노멀 모드에서 컨트롤 Z (언도) -> u, 다시 앞으로 가기 (레도) -> r
vim.keymap.set("n", "u", "u", { silent = true })
vim.keymap.set("n", "r", "<C-r>", { silent = true })

-- 1) 원래 탭 전환이었던 기능을 Ctrl + h, Ctrl + l 로 이동
vim.keymap.set("n", "<C-h>", ":BufferLineCyclePrev<CR>", { silent = true })
vim.keymap.set("n", "<C-l>", ":BufferLineCycleNext<CR>", { silent = true })

-- 2) 기존 탭 전환 자리였던 대문자 H, L (Shift + h, l) 자리에 단어 맨 앞 기준 단어 이동(b, w) 배치
vim.keymap.set("n", "H", "b", { silent = true })
vim.keymap.set("n", "L", "w", { silent = true })

-- 스페이스바 + e : 좌측 폴더 트리 사이드바 토글
vim.keymap.set("n", "<leader>e", ":Neotree toggle left<CR>", { silent = true })

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

-- Normal 모드에서 Tab 키로 코드 창 <-> Neo-tree 파일 트리 포커스 전환
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

-- ==========================================================================
-- 대문자 T (Shift + t) : 현재 파일 경로에서 새 탭에 fish 터미널 명시적 실행
-- ==========================================================================
vim.keymap.set("n", "T", function()
    local current_dir = vim.fn.expand("%:p:h")
    if current_dir == "" then
        current_dir = vim.fn.getcwd()
    end
    vim.cmd("tabnew")
    vim.cmd("lcd " .. vim.fn.fnameescape(current_dir))
    -- 'terminal' 대신 'terminal fish'를 명시하여 확실하게 fish 쉘 실행
    vim.cmd("terminal fish")
    vim.cmd("startinsert")
end, { silent = true })

-- ==========================================================================
-- Alt + h / Alt + l : 현재 탭의 위치를 왼쪽/오른쪽으로 이동 (순서 변경)
-- 혹은 탭 전환으로 쓰고 싶으신 경우 아래 BufferLineCyclePrev/Next로 변경 가능
-- ==========================================================================
vim.keymap.set("n", "<M-h>", ":BufferLineMovePrev<CR>", { silent = true })
vim.keymap.set("n", "<M-l>", ":BufferLineMoveNext<CR>", { silent = true })

-- ==========================================================================
-- 터미널 모드(Terminal mode) 전용 탈출 및 조작 설정
-- ==========================================================================

-- 1) 터미널 모드에서도 jk 또는 kj를 치면 곧바로 Esc 모드(노멀 모드)로 탈출
vim.keymap.set("t", "jk", [[<C-\><C-n>]], { silent = true })
vim.keymap.set("t", "kj", [[<C-\><C-n>]], { silent = true })

-- 2) 기본 Esc 키를 눌러도 터미널 모드에서 노멀 모드로 탈출
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { silent = true })

-- 3) 터미널 화면 클리어(Ctrl + l)는 원본 fish 쉘 기능 그대로 작동하도록 보존 
-- (Ctrl + l을 탭 전환에서 해제하고 원래 기능을 살립니다)
vim.keymap.set("t", "<C-l>", "<C-l>", { silent = true })

-- ==========================================================================
-- 6. 클립보드 연동 설정 (Wayland wl-clipboard)
-- ==========================================================================
vim.g.clipboard = {
    name = 'Wl-Clipboard',
    copy = {
        ['+'] = 'wl-copy',
        ['*'] = 'wl-copy',
    },
    paste = {
        ['+'] = 'wl-paste',
        ['*'] = 'wl-paste',
    },
    cache_enabled = 1,
}

vim.opt.clipboard = 'unnamedplus'
