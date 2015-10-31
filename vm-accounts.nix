{ ... }: {

users.mutableUsers = false;
security.sudo.enable = true;

users.extraUsers.benno = {
  description = "Benno Fünfstück";
  isNormalUser = true;
  home = "/home";
  extraGroups = ["wheel" "docker" "libvirtd" ];
  password = "test";
  subGidRanges = [ { count = 1000; startGid = 100000; } ];
  subUidRanges = [ { count = 1000; startUid = 100000; } ];
};

}
