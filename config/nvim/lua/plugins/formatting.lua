return {
  -- yamlls's formatter (prettier's yaml plugin) reindents sequences nested
  -- under mapping keys but doesn't reindent literal block scalars living
  -- inside them, corrupting multi-line scripts (e.g. `command: - |2 ...`).
  -- Use yamlfmt instead, which round-trips block scalars correctly.
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "yamlfmt" })
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        yaml = { "yamlfmt" },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        yamlls = {
          settings = {
            yaml = {
              format = {
                enable = false,
              },
            },
          },
        },
      },
    },
  },
}
