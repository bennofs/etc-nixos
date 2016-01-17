{ ... }: {

hardware.cpu.intel.updateMicrocode = true;

boot.loader.grub.device = "/dev/sdb";
boot.loader.grub.extraEntries = ''
  menuentry "Windows 10" {
    chainloader (hd1,msdos1)+1;
  }
'';

fileSystems."/data" = {
  label = "data";
  fsType = "ext4";
};

fileSystems."/data/code" = {
  label = "code";
  fsType = "ext4";
};

networking.wireless.interfaces = [ "wlp2s0" ];

}
