{ lib, pkgs, ... }: {

hardware.cpu.intel.updateMicrocode = true;
hardware.enableAllFirmware = true;

fileSystems."/data" = {
  label = "data";
  fsType = "ext4";
};

fileSystems."/home/.data.mount" = {
  label = "data";
  fsType = "ext4";
};

fileSystems."/" = {
  label = "nixos";
  fsType = "ext4";
};

fileSystems."/boot" = {
  label = "esp";
  fsType = "vfat";
};

networking.hostName = "c-cube";
networking.wireless.interfaces = [ "wlp2s0" ];

boot.loader.systemd-boot.enable = true;
boot.loader.efi.canTouchEfiVariables = true;
boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "sr_mod" "rtsx_pci_sdmmc" ];
boot.kernelModules = [ "kvm-intel" ];
boot.extraModulePackages = [ ];

swapDevices = [ ];

services.udev.extraRules = ''
  # spindown /dev/sda after 5 minutes of inactivity
  ACTION=="add", SUBSYSTEM=="block", KERNEL=="sda", RUN+="${pkgs.hdparm}/bin/hdparm -S 60 /dev/sda"
'';

nix.maxJobs = lib.mkDefault 4;

}
