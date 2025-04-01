{
  description = "Standalone Neovim with plugins and custom configuration";

  inputs = { nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable"; };

  outputs = { nixpkgs, ... }:
    let
      # I only use nixos on my PC so I don't give 2 hoots about this now.
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      # Custom epics nvim support
      epics = pkgs.fetchFromGitHub {
        owner = "minijackson";
        repo = "epics.nvim";
        rev = "843c23847bf613c7966a9412e9969d7b240483e9";
        sha256 = "sha256-/0FIxCv5b/+eFNDHhLLgROUwEytIzJy/0sYMMarqljc=";
      };

      # List of Neovim plugins (installed via nixpkgs)
      neovimPlugins = with pkgs.vimPlugins; [
        # Plugins that I know and understand where and how they're used
        nvim-treesitter.withAllGrammars # syntax for everything
        vim-cpp-enhanced-highlight # better looking cpp highlighting
        markdown-preview-nvim # opens markdown preview in browser
        telescope-nvim # Fuzzy search everything
        telescope-fzf-native-nvim # Telescope plugin with native C fzf (faster search)
        telescope-frecency-nvim # Telescope plugin for searching most used files
        lualine-nvim # status bar
        vim-gitbranch # get git info for status bar
        git-worktree-nvim # telescope extension for git worktree
        gitsigns-nvim # git gutter
        vim-fugitive # Git tool
        lazygit-nvim # Another git tool
        impatient-nvim # Everyone and their mother includes this
        incsearch-vim
        nvim-autopairs # autopair braces
        nvim-tree-lua # file tree
        nvim-web-devicons # icons
        base16-nvim # color themes
        comment-nvim # smart comments
        vim-latex-live-preview # preview latex pdf inside editor
        rainbow-delimiters-nvim
        alpha-nvim # greet dashboard
        indentLine # Show indentation levels

        # LSP stuff
        cmp-buffer
        cmp-cmdline
        cmp-nvim-lsp
        cmp-omni
        cmp-path
        cmp-treesitter
        cmp_luasnip
        cmp-nvim-lsp-document-symbol
        cmp-spell
        cmp-nvim-lua
        cmp-emoji
        fidget-nvim
        fzf-lsp-nvim
        lsp_extensions-nvim
        lsp_signature-nvim
        luasnip
        lspkind-nvim
        nvim-cmp
        nvim-dap
        nvim-dap-ui
        nvim-lspconfig
        plenary-nvim

        # Others
        epics
      ];

      # Custom Neovim package with built-in dotfiles
      # Missing a way to bring it's own external tools, like ripgrep and git ...
      myNeovim = pkgs.neovim.override {
        configure = {
          packages.myVimPackage = {
            start = neovimPlugins; # Load all plugins on start
            opt = [ ]; # No optional plugins
          };
          customRC = ''
            set runtimepath+=${./nvim}
            if filereadable(expand("${./nvim/init.vim}"))
              source ${./nvim/init.vim}
            endif
            if filereadable(expand("${./nvim/init.lua}"))
              source ${./nvim/init.lua}
            endif
          '';
        };
      };
    in { packages.${system}.default = myNeovim; };
}
