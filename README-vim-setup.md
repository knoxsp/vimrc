# Vim setup for Python / JavaScript / Vue dev

This pairs with the `.vimrc` in this folder. It uses **vim-plug** as the
plugin manager since it's minimal and fast.

## 1. Install vim-plug

```bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

## 2. Drop in the vimrc

```bash
cp .vimrc ~/.vimrc
```

(Back up your existing `~/.vimrc` first if you have one you care about.)

## 3. Install the plugins

Open vim and run:

```vim
:PlugInstall
```

This pulls down everything listed in the `call plug#begin(...) ... call plug#end()`
block: NERDTree, fzf, ALE, coc.nvim, the Python/JS/Vue syntax plugins, gruvbox, etc.

Requirements for a couple of them:

- **fzf.vim** needs the `fzf` binary. On your Mint/Ubuntu boxes:
  ```bash
  sudo apt install fzf ripgrep
  ```
  (`ripgrep` powers the `:Rg` search mapping.)
- **vim-lsp / asyncomplete** need the actual language servers on your `PATH`
  (Node.js for the JS/Vue ones, pip for pyright). See step 4.

### Why not coc.nvim?

Current coc.nvim releases require **Vim 9.0.0438+ or Neovim 0.8+**. If you're
on Vim 8.2 (check with `vim --version | head -1`), coc.nvim's server will
fail to start with a wall of `E1126`/`E171` errors — that's Vim9-script
syntax inside coc's own plugin code that your vim can't parse, not a config
problem on your end. Rather than force a vim upgrade on a dev box, this
setup uses **vim-lsp + asyncomplete**, which gives the same core features
(completion, go-to-definition, hover, rename) and works fine on Vim 8.1+.

If you'd rather have coc.nvim specifically (nicer floating-window UI, bigger
ecosystem), your options are: upgrade to Neovim (much easier to get a recent
version via `sudo apt install neovim` on newer Ubuntu, or a snap/AppImage),
or build Vim 9 from source. Not necessary for this setup to work, though.

## 4. Install language servers for vim-lsp

`vim-lsp-settings` handles installation for you. Open a file of the relevant
type and run:

```vim
:LspInstallServer
```

- Open a `.py` file → installs **pyright** (needs `pip`/`npm`, either works)
- Open a `.js`/`.ts` file → installs **typescript-language-server**
- Open a `.vue` file → installs **volar** (Vue 3, including `<script setup>`)

You only need to do this once per language; after that the server starts
automatically whenever you open a matching file. Check what's registered
with `:LspManage`.

## 5. Copying to your clipboard when working over SSH

`set clipboard=unnamedplus`/mouse selection only reaches your **local**
clipboard when Vim is running on your own machine. The moment you're SSH'd
into a dev server, Vim has no way to talk to the clipboard on the laptop
you're actually sitting at — a plain yank just goes into Vim's internal
register on the remote box, and whatever ends up on your local clipboard
instead comes from your terminal's own "select text on screen" feature,
which blindly copies whatever's visible, line numbers and all.

The fix is **OSC 52** — an escape sequence Vim can send *through* the SSH
session that tells your local terminal "put this exact text on the
clipboard," bypassing the terminal's own screen-scrape entirely. This
vimrc wires it up via the `vim-oscyank` plugin so it's automatic:

- `:PlugInstall` pulls in `ojroques/vim-oscyank`
- Every `y` (yank) automatically also pushes the yanked text to your local
  clipboard via OSC 52, whether Vim is local or remote

This works with Mint's default terminal (GNOME Terminal, Xfce Terminal —
both VTE-based, both support OSC 52 out of the box). Once `:PlugInstall`
has run on the dev server, `y` and `Ctrl+Shift+V` should behave exactly
like a local editor, no extra key presses needed.

If it still doesn't work after installing: check `echo $TERM` on the remote
box — if it's something unusual (not `xterm-256color` or similar), some
multiplexers (tmux/screen) need an extra `set -g set-clipboard on` in their
own config to pass OSC 52 through without eating it.

## 5. Install the linters/formatters ALE calls out to

ALE doesn't ship the tools themselves, just wires them in.

**Python:**
```bash
pip install --user flake8 pylint black isort
```

**JavaScript/Vue** (per-project is usually better than global, but global works for quick edits):
```bash
npm install -g eslint prettier
```
For project-specific configs, ALE will pick up local `node_modules/.bin/eslint`
and `.eslintrc`/`.prettierrc` automatically if they exist in the project.

## 6. Quick reference of the mappings baked into the vimrc

| Mapping      | Action                          |
|--------------|----------------------------------|
| `,w`         | save                             |
| `,q`         | quit                             |
| `,/`         | clear search highlight           |
| `,n`         | toggle NERDTree                  |
| `,f`         | fzf: find files                  |
| `,g`         | fzf: ripgrep search in project   |
| `,b`         | fzf: list open buffers           |
| `gd`         | go to definition (vim-lsp)       |
| `gr`         | show references (vim-lsp)        |
| `,rn`        | rename symbol (vim-lsp)          |
| `K`          | hover docs (vim-lsp)             |
| `gcc`        | comment/uncomment line           |

Leader key is `,` (comma) — set near the top of the vimrc, easy to change to
space (`let mapleader = "\<space>"`) if you prefer.

## Notes

- ALE is set to auto-fix on save (`black`/`isort` for Python, `prettier` for
  JS/Vue) — if that's too aggressive for a given repo, comment out
  `g:ale_fix_on_save` or set it per-project via a local `.vimrc` + `set exrc`.
- `.vue` files get explicitly recognised as filetype `vue` so syntax and
  coc both treat them correctly — this can otherwise be a common gotcha.
- Indent width defaults to 2 spaces, with Python overridden to 4 via an
  autocmd, matching PEP8 vs typical JS/Vue style.
