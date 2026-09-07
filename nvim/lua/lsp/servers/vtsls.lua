-- NOTE: `setting` below is a typo of `settings` (the LSP client only reads
-- `settings`), and `filestypes` further down is a typo of `filetypes`. Left
-- as-is; this server is also registered with `attach = false` in
-- plugin/lsp.lua so it isn't auto-enabled anyway.
local bin_path = 'vtsls'
local npm_bin_path = vim.fn.exepath('npm')
return {
  cmd = {
    'bunx',
    bin_path,
    '--stdio'
  },
  root_dir = function(bufnr, on_dir)
    -- The project root is where the LSP can be started from
    -- As stated in the documentation above, this LSP supports monorepos and simple projects.
    -- We select then from the project root, which is identified by the presence of a package
    -- manager lock file.
    local root_markers = { 'package.json', 'package-lock.json', 'yarn.lock', 'pnpm-lock.yaml', 'bun.lockb', 'bun.lock' }
    -- Give the root markers equal priority by wrapping them in a table
    root_markers = vim.fn.has('nvim-0.11.3') == 1 and { root_markers } or root_markers
    local project_root = vim.fs.root(bufnr, root_markers)
    if not project_root then
      return
    end

    on_dir(project_root)
  end,

  init_options = {
    hostInfo = 'neovim'
  },

  setting = {
    completionDisableFilterText = false,
    hostInfo = 'neovim',
    npmLocation = npm_bin_path,
    logVerbosity = 'off',
    preferences = {
      allowIncompleteCompletions = false,
      disableSuggestions = false,
      includeCompletionsWithInsertText = true,
    },
    completions = {
      completeFunctionCalls = true
    },
    tsserver = {
      logDirectory = '/tmp',
      logVerbosity = 'verbose'
    },
    experimental = {
      completion = {
        enableServerSideFuzzyMatch = true,
        entriesLimit = 10
      }
    }
  },
  filestypes = {
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescriptreact',
    'typescript.tsx',
    'javascriptreact',
  },
  capabilities = {
    didChangeWatchedFiles = {
      dynamicRegistration = false
    },
    offsetEncoding = { 'utf-8', 'utf-16' },
    textDocument = {
      completion = {
        completionItem = {
          commitCharactersSupport = false,
          deprecatedSupport = false,
          documentationFormat = { 'plaintext', 'markdown' },
          preselectSupport = true,
          snippetSupport = false,
          insertReplaceSupport = true,
        },
        completionItemKind = {
          valueSet = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25 }
        },
        contextSupport = false,
        dynamicRegistration = false
      },
      documentHighlight = {
        dynamicRegistration = false
      },
      documentSymbol = {
        dynamicRegistration = false,
        hierarchicalDocumentSymbolSupport = true,
        symbolKind = {
          valueSet = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26 }
        }
      },
      hover = {
        contentFormat = { 'plaintext' },
        dynamicRegistration = false
      },
      references = {
        dynamicRegistration = false
      },
      signatureHelp = {
        dynamicRegistration = false,
        signatureInformation = {
          documentationFormat = { 'plaintext' }
        }
      },
      rename = true,
      synchronization = {
        didSave = true,
        dynamicRegistration = false,
        willSave = false,
        willSaveWaitUntil = false
      },
      publishDiagnostics = {
        relatedInformation = false
      },
      codeAction = {
        dynamicRegistration = false,
        codeActionLiteralSupport = {
          codeActionKind = {
            valueSet = {
              'quickfix',
              'refactor',
              'refactor.extract',
              'refactor.inline',
              'refactor.rewrite',
              'source',
              'source.organizeImports',
              'source.fixAll',
              'source.addMissingImports',
              'source.removeUnused',
              'source.removeUnusedImports',
              'source.sortImports'
            }
          }
        }
      }
    }
  }
}

