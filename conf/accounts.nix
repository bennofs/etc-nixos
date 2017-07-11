{ ... }: {

users.mutableUsers = false;
security.sudo.enable = true;

users.extraUsers.bennofs = {
  uid = 1000;
  description = "Benno Fünfstück";
  isNormalUser = true;
  createHome = true;
  home = "/home";
  extraGroups = ["wheel" "docker" "libvirtd" ];
  passwordFile = "/etc/local/accounts/bennofs";
  subGidRanges = [ { count = 1000; startGid = 100000; } ];
  subUidRanges = [ { count = 1000; startUid = 100000; } ];
};

}
