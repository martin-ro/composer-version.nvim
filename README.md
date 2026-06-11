# composer-version.nvim

Show the exact installed version of every Composer package as virtual text in `composer.json` — just like PhpStorm's little gray version numbers.

Versions are read from the adjacent `composer.lock`, so what you see is what's actually installed. Fully offline — no Packagist calls, no network requests, no external dependencies.

```jsonc
{
    "require": {
        "php": "^8.4",
        "laravel/framework": "^12.0",     // v12.18.0
        "livewire/livewire": "^3.0"       // v3.6.3
    },
    "require-dev": {
        "pestphp/pest": "^4.0"            // v4.0.3
    }
}
```

*(The annotations above are rendered as gray end-of-line virtual text, not actual file content.)*

## Requirements

- Neovim ≥ 0.10

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    "martin-ro/composer-version.nvim",
    event = { "BufReadPre composer.json" },
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use("martin-ro/composer-version.nvim")
```

### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'martin-ro/composer-version.nvim'
```

## Configuration

The plugin works out of the box with zero configuration. Calling `setup()` is optional:

```lua
require("composer-version").setup({
    highlight = "ComposerVersion", -- highlight group for the virtual text
    enabled = true,                -- render on startup
})
```

The `ComposerVersion` highlight group links to `Comment` by default. Override it to change the color:

```lua
vim.api.nvim_set_hl(0, "ComposerVersion", { fg = "#6c7086", italic = true })
```

## Commands

| Command                    | Description                                  |
| -------------------------- | -------------------------------------------- |
| `:ComposerVersion refresh` | Re-read `composer.lock` and re-render        |
| `:ComposerVersion toggle`  | Toggle the virtual text on/off               |

## How it works

When you open or save a `composer.json`, the plugin looks for a `composer.lock` in the same directory, parses the `packages` and `packages-dev` sections, and annotates every matching dependency line with its locked version using extmark virtual text. Saving `composer.lock` (e.g. after `composer update` in a terminal split) refreshes all open `composer.json` buffers.

If there is no lock file, or it can't be parsed, the plugin silently does nothing.

## License

[MIT](LICENSE)
