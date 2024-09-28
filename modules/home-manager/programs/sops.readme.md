# Generate key ONCE

## Generate a new AGE key

nix shell nixpkgs#age -c age-keygen -o ~/.config/sops/age/keys.txt

## Or generate from an existing SSH key

nix run nixpkgs#ssh-to-age -- -private-key -i ~/.ssh/private > ~/.config/sops/age/keys.txt

## Get the public key from the AGE key

nix shell nixpkgs#age -c age-keygen -y ~/.config/sops/age/keys.txt

# Create the files

## .sops.yaml ( public key infos + path to secrets)

keys:

- &primary <your-public-age-key-here>
  creation_rules:
- path_regex: secrets/secrets.yaml$
  key_groups:
  - age:
    - \*primary

## secret file format

This need to be created on nix flake subdir

```yml
# secrets/secrets.yaml
nextcloud:
  username: your_username
  password: your_password
  url: https://your.nextcloud.instance
```

## Command to encrypt it

Run from nix flake dir

```bash
sops -e -i secrets/secrets.yaml
```

## adding more key to the sops file

cd in to the directory where the .sops.yaml file is located
in this case

```
cd ~/.config/nix/
```

there edit the file by calling sops on it:

```bash
sops modules/sops/kumo.yaml
```

This open the file in $editor so it can be modified

### with more security

Now the command to properly update the key list is like this:

```bash
sudo -E sops updatekeys modules/sops/kumo.yaml
```

\_this rely on sops.nix settings the $SOPS_AGE_KEY_FILE to the correct key file based on host

# Private key

The private key need to be made available to the system that run nixos rebuild.

- SSH ?
- Copy to the system from iso ? ( setup script ??)
