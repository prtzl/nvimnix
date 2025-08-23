{
  description = "Standalone Neovim with plugins and custom configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    inputs:
    let
      # I only use nixos on my PC so I don't give 2 hoots about this now.
      system = "x86_64-linux";
      pkgs = import inputs.nixpkgs { inherit system; };

      commonPackages = with pkgs; [
        bat
        git
        lazygit
        nil # nix lsp
        nixfmt-rfc-style
        python312Packages.python-lsp-server # python lsp
        ripgrep
        sumneko-lua-language-server # lua lsp
        texlab # latex lsp
        tree-sitter
      ];

      # List of Neovim plugins (installed via nixpkgs)
      neovimPlugins = with pkgs.vimPlugins; [

        alpha-nvim # greet dashboard
        base16-nvim # color schemes
        comment-nvim # smart comments
        git-worktree-nvim # telescope extension for git worktree
        gitsigns-nvim # git gutter
        indentLine # Show indentation levels
        lazygit-nvim # Another git tool
        lualine-nvim # status bar
        markdown-preview-nvim # opens markdown preview in browser
        mini-surround # put a symbol around a word
        nvim-autopairs # autopair braces
        nvim-tree-lua # file tree
        nvim-treesitter.withAllGrammars # syntax for everything
        nvim-web-devicons # icons
        rainbow-delimiters-nvim # explains it
        telescope-frecency-nvim # Telescope plugin for searching most used files
        telescope-fzf-native-nvim # Telescope plugin with native C fzf (faster search)
        telescope-nvim # Fuzzy search everything
        vim-asterisk # More options on *
        vim-cpp-enhanced-highlight # better looking cpp highlighting
        vim-fugitive # Git tool
        vim-latex-live-preview # preview latex pdf inside editor
        vim-visual-multi # Multiline select, so good

        # LSP stuff
        cmp-buffer
        cmp-cmdline
        cmp-nvim-lsp
        cmp-nvim-lua
        cmp-path
        cmp-spell
        cmp_luasnip
        fidget-nvim
        lsp_signature-nvim
        lspkind-nvim
        luasnip
        nvim-cmp
        nvim-dap
        nvim-dap-ui
        nvim-lspconfig
        plenary-nvim

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
      makeModule =
        moduleType:
        {
          config,
          lib,
          pkgs,
          ...
        }:
        {
          options.programs.nvimnix = {
            enable = lib.mkEnableOption "Enable nvimnix (Neovim wrapper)";
            # config = lib.mkOption {
            #   type = lib.types.enum [ "home" "nixos" null ];
            #   default = null;
            # };
          };

          config = lib.mkIf config.programs.nvimnix.enable (
            lib.mkMerge [
              # ({
              #   assertions = [{
              #     assertion = config.programs.nvimnix.config != null;
              #     message =
              #       ''nvimnix: Select "home" or "nixos" in `nvimnix.config`!'';
              #   }];
              # })
              (
                if (moduleType == "nixos") then
                  {
                    environment.systemPackages = [ wrappedNeovim ];
                  }
                else
                  { }
              )
              (
                if (moduleType == "home") then
                  {
                    home.packages = [ wrappedNeovim ];
                  }
                else
                  { }
              )
            ]
          );
        };
      nixosModule = makeModule "nixos";
      homeModule = makeModule "home";

    in
    {
      packages.${system}.default = wrappedNeovim;
      nixosModules.nvimnix = nixosModule;
      homeManagerModules.nvimnix = homeModule;
    };
}
