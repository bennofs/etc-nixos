{ lib, ... }: {

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
  device = "/dev/sdb1";
};


networking.wireless.interfaces = [ "wlp2s0" ];

boot.loader.systemd-boot.enable = true;
boot.loader.efi.canTouchEfiVariables = true;
boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "sr_mod" "rtsx_pci_sdmmc" ];
boot.kernelModules = [ "kvm-intel" ];
boot.extraModulePackages = [ ];

swapDevices = [ ];

nix.maxJobs = lib.mkDefault 4;

}
