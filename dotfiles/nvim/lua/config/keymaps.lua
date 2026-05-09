local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Blank lines without moving cursor
map("n", "go", "o<Esc>k", opts)
map("n", "gO", "O<Esc>j", opts)

-- Keep selection when indenting
map("x", ">", ">gv", opts)
map("x", "<", "<gv", opts)

-- Paste without overwriting clipboard
map("x", "p", '"_dP', opts)

-- Clear search
map("n", "<leader>h", "<cmd>nohlsearch<cr>", opts)

-- Lazygit
map("n", "<leader>g", "<cmd>LazyGit<cr>", {
  desc = "Open LazyGit",
})

-- Force quit
map("n", "<leader>q", function()
  local choice = vim.fn.confirm("Really quit?", "&Yes\n&No", 2)
  if choice == 1 then vim.cmd("q!") end
end, { desc = "Quit (!)" })

--------------------------------------------------
-- Smart save (UNCHANGED logic, just moved)
--------------------------------------------------
local function is_in_pwd_and_exists(path, pwd)
  if not path or path == "" then return false end
  local abs = vim.fn.fnamemodify(path, ":p")
  local cwd = vim.fn.fnamemodify(pwd, ":p")
  if cwd:sub(-1) ~= "/" then cwd = cwd .. "/" end
  return abs:sub(1, #cwd) == cwd and vim.fn.filereadable(abs) == 1
end

local function resolve_path_in_pwd(input, pwd)
  local is_abs = input:sub(1, 1) == "/"
    or input:sub(1, 1) == "~"
    or input:match("^%a:[/\\]") ~= nil
  return is_abs and input or (pwd .. "/" .. input)
end

local function prompt_save_into_pwd()
  local cwd = vim.fn.getcwd()
  local default = ""
  local cur = vim.api.nvim_buf_get_name(0)
  if cur ~= "" then default = vim.fn.fnamemodify(cur, ":t") end

  local input = vim.fn.input(
    "Save as (relative to pwd: " .. cwd .. "): ",
    default,
    "file"
  )

  if input == "" then return false end

  local path = resolve_path_in_pwd(input, cwd)
  local dir = vim.fn.fnamemodify(path, ":h")
  if dir ~= "" and vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p")
  end

  vim.cmd("saveas! " .. vim.fn.fnameescape(path))
  return true
end

local function smart_write_in_pwd()
  local bufname = vim.api.nvim_buf_get_name(0)
  local cwd = vim.fn.getcwd()
  if is_in_pwd_and_exists(bufname, cwd) then
    vim.cmd("write")
  else
    prompt_save_into_pwd()
  end
end

local function smart_write_then_quit_in_pwd()
  smart_write_in_pwd()
  vim.cmd("bd")
end

map("n", "<leader>w", smart_write_in_pwd,
  { desc = "Write or Save As into pwd" })
map("n", "<leader>x", smart_write_then_quit_in_pwd,
  { desc = "Write/Save As then quit" })

-- Cheatsheet
map("n", "<leader>?", function() require("config.cheatsheet").open() end, { desc = "Cheatsheet" })