# Minecraft Fabric Server

A Docker-based Minecraft Fabric server for Unraid with automatic mod syncing, scheduled backups, and performance optimizations.

## Versions
**Minecraft Version:** 1.21.11
**Fabric Version:** 0.18.4

## Features

- **Fabric Mod Loader** - Lightweight, fast modding platform
- **Packwiz Integration** - Automatic mod syncing for server and clients
- **Dual Backup System** - Hourly (3-day retention) and daily (30-day retention)
- **Auto-Pause** - Server pauses when empty to save resources

## Mods

### Performance & Optimization

| Mod | Side | Purpose |
|-----|------|---------|
| [Fabric API](https://modrinth.com/mod/fabric-api) | Both | Required mod framework |
| [Lithium](https://modrinth.com/mod/lithium) | Both | Game logic optimization |
| [FerriteCore](https://modrinth.com/mod/ferritecore) | Both | Memory usage reduction |
| [Krypton](https://modrinth.com/mod/krypton) | Server | Network stack optimization |
| [Sodium](https://modrinth.com/mod/sodium) | Client | Rendering performance (3-5x FPS) |

### Gameplay

| Mod | Side | Purpose |
|-----|------|---------|
| [Universal Graves](https://modrinth.com/mod/universal-graves) | Server | Graves drop on death instead of losing items |
| [Configurable Despawn Timer](https://modrinth.com/mod/configurable-despawn-timer) | Server | Adjust how long items stay on ground |

### Quality of Life

| Mod | Side | Purpose |
|-----|------|---------|
| [AppleSkin](https://modrinth.com/mod/appleskin) | Both | Shows food/saturation values |
| [MiniHUD](https://modrinth.com/mod/minihud) | Client | Customizable miniF3 screen |
| [Enchantment Descriptions](https://modrinth.com/mod/enchantment-descriptions) | Client | Shows what enchantments do |
| [JEI (Just Enough Items)](https://modrinth.com/mod/jei) | Both | Recipe viewer |
| [Mouse Tweaks](https://modrinth.com/mod/mouse-tweaks) | Client | Better inventory mouse controls |
| [Shulker Box Tooltip](https://modrinth.com/mod/shulkerboxtooltip) | Both | Preview shulker box contents |

### Visual

| Mod | Side | Purpose |
|-----|------|---------|
| [Iris](https://modrinth.com/mod/iris) | Client | Shader support for Fabric (just in case) |
| [LambDynamicLights](https://modrinth.com/mod/lambdynamiclights) | Client | Held torches emit light |

### Building Tools

| Mod | Side | Purpose |
|-----|------|---------|
| [Litematica](https://modrinth.com/mod/litematica) | Client | Schematic mod for building |

### UI

| Mod | Side | Purpose |
|-----|------|---------|
| [ModMenu](https://modrinth.com/mod/modmenu) | Client | In-game mod configuration |

### Libraries (Auto-installed)

| Mod | Required By |
|-----|-------------|
| [Collective](https://modrinth.com/mod/collective) | Configurable Despawn Timer |
| [MaLiLib](https://modrinth.com/mod/malilib) | Litematica |
| [Placeholder API](https://modrinth.com/mod/placeholder-api) | ModMenu |
| [Prickle](https://modrinth.com/mod/prickle) | Enchantment Descriptions |
| [Polymer](https://modrinth.com/mod/polymer) | Universal Graves |

## Backups
### Automatic Backups
| Type | Schedule | Retention | Location |
|------|----------|-----------|----------|
| Hourly | Every hour (when players are online) | 3 days | {BACKUP_PATH}/hourly/ |
| Daily | 4:00 AM | 30 days | {BACKUP_PATH}/daily/ |

### Manual Backups
```
docker exec minecraft-backup-hourly backup now
```

### Restore from Backup
1. Stop the docker stack
2. Extract backup
```
cd {APPDATA_PATH}/minecraft-fabric
tar -xzf {BACKUP_PATH}/daily/world-daily-YYYY-MM-DD.tar.gz
```
3. Fix permissions
```
chown -R 99:100 {APPDATA_PATH}/minecraft-fabric
```
4. Start the docker stack

## Player Instructions
Step 1: Install Prism Launcher
Download and install Prism Launcher for your operating system

Step 2: Add Your Minecraft Account
1. Open Prism Launcher
2. You will likely be prompted to add a Microsoft account
If you're not prompted to add one, click Accounts in the top-right
3. Click Add Microsoft
4. Sign in with your Microsoft/Minecraft account

Step 3: Create Server Instance
1. Click Add Instance
2. Set name: (optional)
3. Select type: custom
4. Select Minecraft version
5. Select mod loader: Fabric
6. Select Fabric version
7. Click OK

Step 4: Download Packwiz Bootstrap
1. Download [packwiz-installer-bootstrap.jar](https://github.com/packwiz/packwiz-installer-bootstrap/releases/latest/download/)
2. Right-click your instance → Folder
3. Open the minecraft folder
4. Place packwiz-installer-bootstrap.jar in the minecraft folder

Step 5: Configure Auto-Sync
1. Right-click your instance → Edit
2. Go to Settings → Custom commands
3. Check Pre-launch command
4. Paste this command:
```
"$INST_JAVA" -jar packwiz-installer-bootstrap.jar https://raw.githubusercontent.com/Michael-XKCD/docker-compose/main/minecraft-fabric-server/packwiz/pack.toml
```
5. Click Close

Step 6: Launch and Play!
Double-click your instance to launch.
Packwiz will automatically download all required mods.
When the server admin adds or updates mods, Packwiz automatically downloads the changes next time you launch the game.

## Managing Mods
### Add new mods from Modrinth
Find the mod(s) you want to add on [Modrinth](https://modrinth.com/)
Add the mod(s) to the server with packwiz
```
packwiz modrinth add <mod-name>
```
Refresh index
```
packwiz refresh
```
Then commit and push the change to the repo.
Restart the server for server-side mods. Clients will add the new mod(s) on next launch.

### Remove a mod
Similar to adding mods, remove mods with packwiz
```
packwiz remove <mod-name>
```
Refresh index
```
packwiz refresh
```
Then commit and push the change to the repo.
Restart the server for server-side mods. Clients will sync-up on next launch.

### Update All Mods
```
packwiz update --all
packwiz refresh
```
Then commit and push the change to the repo.
Restart the server for server-side mods. Clients will auto-update on next launch.
