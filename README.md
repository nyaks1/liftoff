# Linux Dev Environment Installer

One-shot bash script to install a development environment on Debian/Ubuntu-based Linux systems.

## What It Installs

| Tool              | Method                              |
|-------------------|-------------------------------------|
| Python 3 + pip    | `apt`                               |
| VS Code           | `snap` or Microsoft APT repo       |
| IntelliJ IDEA CE  | `snap` or JetBrains Toolbox        |
| Google Chrome      | Direct `.deb` from Google           |
| Brave Browser     | Brave APT repository                |

## Requirements

- Debian/Ubuntu-based Linux (Ubuntu 20.04+, Debian 11+)
- `sudo` privileges
- Internet connection
- A terminal

## Usage

```bash
# Clone the repo
git clone <your-repo-url>
cd <repo-name>

# Make executable
chmod +x install.sh

# Run it
./install.sh
```

The script will prompt you to confirm before installing anything.

## What Happens

1. Detects your Linux distribution
2. Shows you a list of software to be installed
3. Asks for confirmation
4. Installs each tool, skipping anything already present
5. Reports success or failure per component

## Skips Existing Installs

Each function checks if the tool is already installed. If so, it prints a warning and moves on — no redundant reinstalls.

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `snap: command not found` | Install snapd: `sudo apt install snapd` |
| `gpg` errors on Chrome | Run `sudo apt install gnupg` |
| Brave keyring fails | Check your internet connection |
| Permission denied | Don't run with `sudo` — the script uses `sudo` internally |

## Customization

Edit the `main()` function to add or remove installers. Each tool is isolated in its own function for easy maintenance.

## License

MIT
