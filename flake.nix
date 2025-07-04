{
  description = "Standalone Neovim with plugins and custom configuration";

  inputs = { nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable"; };

  outputs = { nixpkgs, ... }:
    let
      # I only use nixos on my PC so I don't give 2 hoots about this now.
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      commonPackages = with pkgs; [
        git
        bat
        ripgrep
        nil # nix lsp
        texlab # latex lsp
        python312Packages.python-lsp-server # python lsp
        sumneko-lua-language-server # lua lsp
        tree-sitter
        lazygit
      ];

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
        alpha-nvim # greet dashboard
        base16-nvim # color schemes
        comment-nvim # smart comments
        git-worktree-nvim # telescope extension for git worktree
        gitsigns-nvim # git gutter
        impatient-nvim # Everyone and their mother includes this
        incsearch-vim
        indentLine # Show indentation levels
        lazygit-nvim # Another git tool
        lualine-nvim # status bar
        markdown-preview-nvim # opens markdown preview in browser
        mini-surround # put a symbol around a word
        nvim-autopairs # autopair braces
        nvim-tree-lua # file tree
        nvim-treesitter.withAllGrammars # syntax for everything
        nvim-web-devicons # icons
        rainbow-delimiters-nvim
        telescope-frecency-nvim # Telescope plugin for searching most used files
        telescope-fzf-native-nvim # Telescope plugin with native C fzf (faster search)
        telescope-nvim # Fuzzy search everything
        vim-cpp-enhanced-highlight # better looking cpp highlighting
        vim-fugitive # Git tool
        vim-gitbranch # get git info for status bar
        vim-latex-live-preview # preview latex pdf inside editor
        vim-obsession # Save sessions. Used by tmux-ressurect
        vim-visual-multi # Multiline select, so good

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

      # Very cowboy approach but it works
      wrappedNeovim = pkgs.writeShellApplication {
        name = "nvim";
        runtimeInputs = commonPackages ++ [ myNeovim ];
        text = ''
          nvim "$@"
        '';
      };

      # Ok so I could NOT select either home or nixos with option and switch the lazy if for either or.
      # Got only infinite recursion. Damn, so let's do this the manual way.
      makeModule = moduleType:
        { config, lib, pkgs, ... }: {
          options.programs.nvimnix = {
            enable = lib.mkEnableOption "Enable nvimnix (Neovim wrapper)";
            # config = lib.mkOption {
            #   type = lib.types.enum [ "home" "nixos" null ];
            #   default = null;
            # };
          };

          config = lib.mkIf config.programs.nvimnix.enable (lib.mkMerge [
            # ({
            #   assertions = [{
            #     assertion = config.programs.nvimnix.config != null;
            #     message =
            #       ''nvimnix: Select "home" or "nixos" in `nvimnix.config`!'';
            #   }];
            # })
            (if (moduleType == "nixos") then {
              environment.systemPackages = [ wrappedNeovim ];
            } else
              { })
            (if (moduleType == "home") then {
              home.packages = [ wrappedNeovim ];
            } else
              { })
          ]);
        };
      nixosModule = makeModule "nixos";
      homeModule = makeModule "home";

    in {
      packages.${system}.default = wrappedNeovim;
      nixosModules.nixos = nixosModule;
      nixosModules.home = homeModule;
    };
}
