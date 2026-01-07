{
  description = "Standalone Neovim with plugins and custom configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ nixpkgs, flake-parts, ... }:
    let
      makeNeovim =
        pkgs:
        let
          commonPackages = with pkgs; [
            bat
            git
            lazygit
            nil # nix lsp
            nixfmt
            python313Packages.python-lsp-server # python lsp
            ripgrep
            lua-language-server # lua lsp
            texlab # latex lsp
            tree-sitter
          ];

          # List of Neovim plugins (installed via nixpkgs)
          neovimPlugins = with pkgs.vimPlugins; [
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

          myNeovimConfig = pkgs.neovimUtils.makeNeovimConfig {
            plugins = neovimPlugins;
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

          myNeovim = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped myNeovimConfig;

          # I need to wrap my neovim in shell script so that common packages needed at runtime are available
          wrappedNeovim = pkgs.writeShellApplication {
            name = "nvim";
            runtimeInputs = commonPackages ++ [ myNeovim ];
            text = ''exec nvim "$@"'';
          };
        in
        wrappedNeovim;

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
            useModulePkgs = lib.mkOption {
              default = true;
              example = false;
              description = "Use this flake's pkgs instead of host pkgs";
              type = lib.types.bool;
            };
          };
          config =
            let
              nvim-pkgs =
                if config.programs.nvimnix.useModulePkgs then
                  nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}
                else
                  pkgs;
            in
            lib.mkIf config.programs.nvimnix.enable (
              lib.mkMerge [
                (
                  if (moduleType == "nixos") then
                    {
                      # make sure that system-wide neovim is disabled when including this one
                      programs.neovim.enable = lib.mkForce false;
                      environment.systemPackages = [ (makeNeovim nvim-pkgs) ];
                    }
                  else
                    { }
                )
                (
                  if (moduleType == "home") then
                    {
                      # make sure that system-wide neovim is disabled when including this one
                      programs.neovim.enable = lib.mkForce false;
                      home.packages = [ (makeNeovim nvim-pkgs) ];
                    }
                  else
                    { }
                )
              ]
            );
        };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake = {
        nixosModules.default = makeModule "nixos";
        homeManagerModules.default = makeModule "home";
      };

      # systems = nixpkgs.legacyPackages.x86_64-linux.neovim.meta.platforms;
      # so neovim derivation has meta.platforms = lib.platforms.all;
      # This causes issues with pkgs not being available for some, like aarch64-freebsd
      # Just define main platforms that a normal person would use (for now)
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem =
        { pkgs, system, ... }:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          formatter = pkgs.nixfmt-tree;
          packages.default = makeNeovim pkgs;
        };
    };
}
