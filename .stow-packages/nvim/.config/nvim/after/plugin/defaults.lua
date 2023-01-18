require('lualine').setup {
  options = {
    theme = 'dracula',
  },
}

require("mason-lspconfig").setup {
  ensure_installed = { 
    "bash-language-server", "bash-debug-adapter",
    "sumneko_lua", "rust_analyzer",
    "ruby-lsp", "solargraph", "sorbet",
    "typescript-language-server", "json-lsp",
    "kotlin-language-server", "kotlin-debug-adapter",
  },
}

require('nvim-treesitter.configs').setup {
  ensure_installed = {
    'lua', 'vim',
    'bash', 'regex', 'awk', 'diff', 'help', 'dockerfile',
    'gitattributes', 'gitcommit', 'git_rebase',
    'html', 'css', 'scss',
    'javascript', 'json', 'jq',
    'typescript', 'tsx', 'graphql',
    'yaml', 'toml', 'markdown',
    'c', 'cpp', 'go', 'rust',
    'ruby', 'python', 'kotlin', 'java',
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '+',
      node_incremental = '+',
      scope_incremental = '<c-s>',
      node_decremental = '-',
    },
  },
  autotag = { enable = true },
  endwise = { enable = true },
  textsubjects = {
    enable = true,
    prev_selection = ',', -- (Optional) keymap to select the previous selection
    keymaps = {
      ['.'] = 'textsubjects-smart',
      [';'] = 'textsubjects-container-outer',
      ['i;'] = 'textsubjects-container-inner',
    },
  },
}

local luasnip = require('luasnip')
local cmp = require('cmp')
cmp.setup {
  mapping = cmp.mapping.preset.insert {
    ['<C-Space>'] = cmp.mapping.complete({}),
    ['<C-]>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<C-J>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<C-K>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
}

-- Toggle Term
local toggleterm = require('toggleterm')
toggleterm.setup {
  size = 13,
  open_mapping = [[<c-\>]],
  shade_filetypes = {},
  shade_terminals = true,
  shading_factor = '1',
  start_in_insert = true,
  persist_size = true,
  direction = 'horizontal'
}
local toggle_terminal = function()
  local Terminal = require('toggleterm.terminal').Terminal
  local float = Terminal:new({ direction = "float" })
  return float:toggle()
end
local toggle_lazygit = function()
  local Terminal = require('toggleterm.terminal').Terminal
  local lazygit = Terminal:new({ cmd = "lazygit", direction = "float" })
  return lazygit:toggle()
end
local toggle_lf = function()
  local Terminal = require('toggleterm.terminal').Terminal
  local ranger = Terminal:new({ cmd = "lf", direction = "float" })
  return ranger:toggle()
end


-- WhichKey mappings
local opts = { prefix = "<leader>" }
local mappings = {
  t = {
    name = "[t]oggle term",
    l = { toggle_lazygit, '[l]azygit' },
    t = { toggle_terminal, '[terminal]' },
    f = { toggle_lf, '[f]ile manager' }
  },
  s = {
    name = "[s]earch"
  },
  c = {
    name = "[c]ode"
  },
  e = { ":!ruby %<CR>", "Execute Ruby" },
  b = { ":!bundle exec rspec %<CR>", "Bundle exec" },
  r = { ":!rspec . --color --format doc<CR>", "Rspec" },
  f = { ":Format<CR>", "Format" },
  i = { "m'gg=G''", "Indent" },
  x = { ":bdelete<cr>", "E[x]it Buffer" },
  X = { ":bdelete!<cr>", "Force e[X]it" },
  q = { ":q<cr>", "[q]uit" },
  Q = { ":q!<cr>", "Force [Q]uit" },
  w = { ":w<cr>", "[w]rite file" },
  E = { ":e ~/.config/nvim/init.lua<cr>", "[E]dit nvim config" },
  p = {
    name = "[p]acker",
    r = { ":PackerClean<cr>", "[r]emove unused plugins" },
    c = { ":PackerCompile profile=true<cr>", "[c]ompile plugins" },
    i = { ":PackerInstall<cr>", "[i]nstall plugins" },
    p = { ":PackerProfile<cr>", "Packer [p]rofile" },
    s = { ":PackerSync<cr>", "[s]ync plugins" },
    S = { ":PackerStatus<cr>", "packer [S]tatus" },
    u = { ":PackerUpdate<cr>", "[u]pdate plugins" }
  },
}

require('which-key').register(mappings, opts)
require('nvim-autopairs').setup({})

-- Map 'jk', 'kj', 'jj', 'kk' to ESC
for _, v in ipairs({ 'jk', 'kj' }) do
  vim.keymap.set('i', v, '<ESC>', { noremap = true })
end

-- Settings
vim.o.clipboard = "unnamedplus"
vim.o.timeoutlen = 150
vim.cmd [[colorscheme dracula]]
