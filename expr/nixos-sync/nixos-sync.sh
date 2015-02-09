set +eu
checkout=$(sudo -u nobody mktemp -d)
function finish {
    rm -rf $checkout
}
trap finish EXIT

sudo -u nobody git clone --recursive /home/nixos $checkout
chown root:root -R $checkout
chmod a-w -R $checkout
chmod a+x -R $checkout
cd /etc/nixos
sudo -u nobody env GIT_ALTERNATE_OBJECT_DIRECTORIES=$checkout/.git/objects git diff HEAD..$(git --git-dir=$checkout/.git rev-parse HEAD)

read -r -p "Accept? [Y/n] " response
response=${response,,} # tolower
if [[ $response =~ ^(yes|y| ) ]]; then
  git pull --ff $checkout
  git submodule update --init --recursive
  nixos-rebuild switch
fi
