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

    -- Nvimgelion 컬러스킴 테마 플러그인
    {
        "nyngwang/nvimgelion",
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd("colorscheme nvimgelion")
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
                
                -- 그냥 nvim을 켰을 때도 마지막으로 작업하던 프로젝트 폴더를 찾아 자동 복원하도록 타겟 설정
                auto_session_enable_last_session = true, 
                
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
-- 4. 네오빔 시작 시 파일 트리 강제 실행 자동화 스크립트 (어디서 켜든 자동 시작 보장)
-- ==========================================================================
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        -- 세션 복원이 이루어지지 않은 일반 빈 화면인 경우 좌측 파일 트리를 무조건 오픈
        if vim.fn.argc() == 0 then
            vim.cmd("Neotree show")
        end
    end
})

-- ==========================================================================
-- 5. VS Code 스타일 조작 및 탭 관리 단축키 매핑
-- ==========================================================================
-- 스페이스바 + e : 좌측 폴더 트리 사이드바 토글
vim.keymap.set("n", "<leader>e", ":Neotree toggle left<CR>", { silent = true })

-- 대문자 H / L (Shift + h/l) : 왼쪽 / 오른쪽 파일 탭으로 포커스 이동
vim.keymap.set("n", "H", ":BufferLineCyclePrev<CR>", { silent = true })
vim.keymap.set("n", "L", ":BufferLineCycleNext<CR>", { silent = true })

-- Alt + h / Alt + l : 현재 파일 탭 위치를 왼쪽 / 오른쪽으로 이동 (순서 변경)
vim.keymap.set("n", "<M-h>", ":BufferLineMovePrev<CR>", { silent = true })
vim.keymap.set("n", "<M-l>", ":BufferLineMoveNext<CR>", { silent = true })

-- 스페이스바 + q : 현재 열려있는 파일 탭 강제 닫기 
vim.keymap.set("n", "<leader>q", ":bdelete!<CR>", { silent = true })
