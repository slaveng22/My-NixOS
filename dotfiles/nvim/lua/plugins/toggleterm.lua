require("toggleterm").setup({
  size = function(term)
    if term.direction == "horizontal" then
      return 10
    elseif term.direction == "vertical" then
      return vim.o.columns * 0.3
    end
  end,
  open_mapping = [[<C-t>]],
  hide_numbers = true,
  shade_terminals = true,
  start_in_insert = true,
  insert_mappings = false,
  terminal_mappings = false,
  direction = "float",
  close_on_exit = true,
  shell = vim.o.shell,
  float_opts = {
    border = "curved",
    winblend = 0,
    width = math.floor(vim.o.columns * 0.6),
    height = math.floor(vim.o.lines * 0.5),
  },
  on_open = function(term)
    term:send("cd " .. vim.fn.shellescape(vim.fn.getcwd()) .. " && clear", false)
  end,
})

local Terminal = require("toggleterm.terminal").Terminal

vim.keymap.set("t", "<C-t>", "<cmd>ToggleTerm<cr>", { desc = "Toggle terminal" })
