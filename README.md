# nixos-config

<img width="1180" alt="PNG image" src="https://user-images.githubusercontent.com/5546264/188339768-da20bdbc-d80e-441b-8a9f-a90239b6e4b4.png">

## Commands

```zsh
# update flake
% nix flake update
```

```zsh
# rebuild system
% sudo nixos-rebuild switch --flake '.#nuc'
```

## My Notes

https://www.mccurdyc.dev/posts/2022/09/nixos-config/

## Inspiration

- [phamann/nixos-config](https://github.com/phamann/nixos-config)
- [notusknot/dotfiles-nix](https://github.com/notusknot/dotfiles-nix)
- [kclejeune/system](https://github.com/kclejeune/system)
- [mitchellh/nixos-config](https://github.com/mitchellh/nixos-config)

## Thanks

I couldn't have done it without the help of two friends: @phamann and @whiteley.

@whiteley was the one who kept on me about trying Nix and NixOS out in our weekly
1:1s.

@phamann helped me achieve NeoVim packages via the Flake and took the time to
help me understand Overlays. Check out @phamann's nixos-configs.

- [phamann/nixos-config](https://github.com/phamann/nixos-config)
