# Standalone home-manager on a non-NixOS desktop. The window manager or
# desktop environment comes from the host distribution.
{
  imports = [
    ./default.nix
    ../../modules/linux/desktop.nix
  ];

  # Links Nix's OpenGL/Vulkan drivers into /run/opengl-driver. Needs a one-time
  # `sudo non-nixos-gpu-setup`; activation prints the exact command.
  targets.genericLinux.gpu.enable = true;
}
