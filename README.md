Hi :)

### Fresh install

```bash
git clone --recursive git@github.com:gabriel-suela/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install
```

`./install` first applies the symlinks with Dotbot and then runs [`setup.sh`](/home/suela/dotfiles/setup.sh).

### Update dotbot submodule

```bash
git submodule update --init --recursive
```
