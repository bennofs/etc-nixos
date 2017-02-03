{ ... }: {

hardware.cpu.intel.updateMicrocode = true;

boot.loader.grub.device = "/dev/sdb";
boot.loader.grub.extraEntries = ''
  menuentry "Windows 10" {
    set root=(hd0,msdos1);
    chainloader (hd0,msdos1)+1;
  }
'';

fileSystems."/data" = {
  label = "data";
  fsType = "ext4";
};

fileSystems."/home/.data.mount" = {
  label = "data";
  fsType = "ext4";
};

fileSystems."/code" = {
  label = "code";
  fsType = "ext4";
};

networking.wireless.interfaces = [ "wlp2s0" ];

boot.kernelParams = [ "libata.force=6.00:noncq" ];

}
