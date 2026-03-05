#!/usr/bin/env bash
# modules/red/macos.sh

red_macos() {
    show_page "🍎 RED — MacOS Enumeration" \
"═══════════════════════════════════════════════════════════════
  MacOS Enumeration                                    [RED]
═══════════════════════════════════════════════════════════════

  SITUATIONAL AWARENESS
    ls /Applications          Installed apps
    hostname                  Computer name
    id                        Current user
    w                         Logged on users
    last                      Past logins
    df -h                     Disk usage
    uname -a                  Kernel + CPU
    mount                     Mounted drives

  FILE SYSTEM STRUCTURE
    /Applications             Mail, Safari, apps
    /bin                      User binaries
    /dev                      Device interfaces
    /etc                      Config files
    /Users                    User home dirs
    /Library                  Critical libraries
    /private                  System files + caches
    /opt                      Optional packages
    /usr                      Unix software
    /var                      Variable data
    /tmp                      Temp files

  USER PLIST ENUMERATION
    sudo plutil -p /var/db/dslocal/nodes/Default/users/<USER>.plist
    sudo dscl . read Users/<USER> ShadowHashData

  USER ENUMERATION & MODIFICATION
    dscl . list /Users                    All users + daemons
    dscl . list /Users | grep -v '_'      Actual users only
    dscacheutil -q user                   Verbose user info
    dscl . -read /Users/<USER>            Very verbose

  GROUP ENUMERATION
    dscacheutil -q group -a name <GROUP>

  CREATE USER
    dscl . -create /Users/<USER>
    dscl . -create /Users/<USER> UserShell /bin/bash
    dscl . -create /Users/<USER> RealName \"<DISPLAY_NAME>\"
    dscl . -create /Users/<USER> UniqueID \"<ID>\"
    dscl . -create /Users/<USER> PrimaryGroupID 20
    dscl . -create /Users/<USER> NFSHomeDirectory /Users/<USER>
    mkdir /Users/<USER>
    dscl . -passwd /Users/<USER> <PASSWORD>

  ADD USER TO ADMIN GROUP
    sudo dscl . -append /Groups/admin GroupMembership <USER>

  CREATE GROUP
    sudo dscl . -create /Groups/<GROUP>
    sudo dscl . -create /Groups/<GROUP> RealName \"<NAME>\"
    sudo dscl . -create /Groups/<GROUP> passwd \"*\"
    dscl . list /Groups PrimaryGroupID | tr -s ' ' | sort -n -t ' ' -k2,2
    sudo dscl . -create /Groups/<GROUP> gid <ID>
    sudo dscl . -create /Groups/<GROUP> GroupMembership <USER>

  NETWORK
    networksetup -listallnetworkservices
    networksetup -getinfo <IF>
    ifconfig

  DNS ZONE TRANSFER
    dig axfr <DOMAIN> @<DNS_IP>
    host -t axfr <DOMAIN> <DNS_IP>

  MACOS VERSIONS REFERENCE
    10.15  Catalina     2019-10-07
    11.x   Big Sur      2020-11-12
    12.x   Monterey     2021-10-25
    13.x   Ventura      2022-10-24
    14.x   Sonoma       2023-09-26
    15.x   Sequoia      2024-09-16"
}
