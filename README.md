# NvimNIX

Nvim configured with NIX. Makes sense. The nvim folder is compatible with regular nvim installation, but the nix flake provides locked apps, plugins, and "system dependencies" required by all components.

This way if anything breaks in the future, either nvim, plugin, or system-wise, this will continue working **until I break it**.

The approach is very cowboy. The nvim package is taken from nixpkgs with the init lua and plugins attached to it. This essentially rebuilds the last part of the package.

The advantage of this is that you can run it anytime from anywhere if you have nix installed:

## Standalone

```bash
nix run github:prtzl/nvimnix
```
Plugins require some dependencies like ripgrep, fd, etc. Normally user would have to provide those even when plugin managers are used. Nix also takes care of that. Even more, it pulls them from the same nixpkgs as everything else, meaning everything is tested together. It is not relying on the user's machine and wheather they have those installed or not (or at the correct version).

These dependencies will be sourced before nvim (wrapped shell script) is started and won't matter what you have on your system. Top shit!

## nixos or home-manager

You can add it to your home/nixos flake inputs and source either of the modules:

```nix
nvimnix.nixosModules.default <------------ nixos
nvimnix.homeManagerModules.nvimnix <------ home-manager
```

Then you can just enable it in your nixos or home-manager:

```nix
programs.nvimnix.enable = true;
```

As mentioned before it is handy that it uses it's own copy of nixpkgs in case something updates upstream. Even something not explicitly used in the derivation (transitive dependency) might break shit.

That's why in my system I decided not to follow this flake's nixpkgs to my nixos/home-manager system. It would save space (copies of packages), but could break something in future without me noticing. Better to update nvim along with nixpkgs separately.

Just my two cents.

Feel free to read my (old) [nixos configuration](https://github.com/prtzl/nixos) or my [new one](https://github.com/prtzl/trilby) using [trilby](https://github.com/ners/trilby) by @ners.
