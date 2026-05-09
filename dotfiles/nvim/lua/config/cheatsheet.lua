local M = {}

M.entries = {
  {
    title = "Quote word",
    body = [[
1. ciw'<ESC>p - Quote with single quotes 
2. ciw"<ESC>p - Quote with double quotes

  ciw  → delete inner word (stored in register)
  "    → type opening quote
  <ESC>→ exit insert mode
  p    → paste deleted word after cursor
]],
  },
  {
    title = "Unquote word (remove surrounding quotes)",
    body = [[
di'va'p   — for single quotes
di"va"p   — for double quotes

  di'  → delete inside single quotes (word into register)
  va'  → select around single quotes (including quotes)
  p    → paste word over selection (replaces quotes + word)
]],
  },
  {
    title = "Project-wide find & replace",
    body = [[
1. <leader>sg / <leader>sG  — grep (root / cwd)
2. Find the text, press CTRL+q  → send to quickfix
3. Run: :cfdo %s/old/new/gc | update

  :cfdo          → run on every quickfix file
  %s/old/new/gc  → replace with confirmation
  | update       → save each file
]],
  },
  {
    title = "Increment/decrement numbers in visual block",
    body = [[
1. CTRL+v  — visual block mode
2. Select column of numbers
3. g CTRL+a  — increment sequentially (1,2,3...)
   g CTRL+x  — decrement sequentially

  CTRL+a/x alone → same value for all lines
  g CTRL+a/x     → sequential increment/decrement
]],
  },
  {
    title = "Run macro on visual selection",
    body = [[
1. Record macro: qa ... q  (record into register a)
2. Select lines in visual mode
3. :'<,'>normal @a

  :'<,'>      → range of visual selection
  normal @a   → run macro 'a' on each line
]],
  },
  {
    title = "Sort and remove duplicate lines",
    body = [[
Visual select lines, then:
  :'<,'>sort u

Or entire file:
  :%sort u

  sort   → alphabetically sort
  u flag → remove duplicates
]],
  },
  {
    title = "Align text on a character",
    body = [[
Visual select lines, then:
  :'<,'>!column -t -s '=' -o '='

Aligns on '=' character (change as needed)

  column -t  → create table
  -s '='     → split on '='
  -o '='     → output separator '='
]],
  },
  {
    title = "Swap two words",
    body = [[
Place cursor on first word:
  dawwP

  daw  → delete a word (into register)
  w    → move to next word
  P    → paste before cursor (swaps positions)
]],
  },
  {
    title = "Join lines with custom separator",
    body = [[
Visual select lines, then:
  :s/\n/, /g

Joins with ', ' — change separator as needed

Or join without spaces:
  :s/\n//g
]],
  },
  {
    title = "Edit remote files",
    body = [[
nvim scp://user@host//absolute/path/to/file
nvim scp://user@host/relative/to/home

Browse remote directory:
  nvim scp://user@host/

Tip: add host to ~/.ssh/config for short names:
  Host myserver
    HostName 192.168.1.10
    User slaven

  Then: nvim scp://myserver//etc/nginx/nginx.conf

All local plugins (LSP, formatting, etc.) work normally.
]],
  },
}

function M.open()
  local fzf = require("fzf-lua")
  local titles = {}
  for i, e in ipairs(M.entries) do titles[i] = i .. ". " .. e.title end

  fzf.fzf_exec(titles, {
    prompt = "Cheatsheet> ",
    actions = {
      ["default"] = function(selected)
        if not selected or not selected[1] then return end
        local idx = tonumber(selected[1]:match("^(%d+)%."))
        local lines = vim.split(M.entries[idx].body, "\n")
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        local width = 0
        for _, l in ipairs(lines) do width = math.max(width, #l) end
        vim.api.nvim_open_win(buf, true, {
          relative = "editor",
          width = math.min(width + 2, vim.o.columns - 4),
          height = #lines,
          row = math.floor((vim.o.lines - #lines) / 2),
          col = math.floor((vim.o.columns - width) / 2),
          style = "minimal", border = "rounded",
          title = " " .. M.entries[idx].title .. " ", title_pos = "center",
        })
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })
        vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, silent = true })
      end,
    },
  })
end

return M
