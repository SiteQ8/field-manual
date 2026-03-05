#!/usr/bin/env bash
# modules/blue/recover.sh

blue_recover() {
    show_page "🏥 BLUE — Recover" \
"═══════════════════════════════════════════════════════════════
  BLUE — Recover                                       [BLUE]
═══════════════════════════════════════════════════════════════

  WINDOWS — System File Checker
    C:\> sfc /scannow
    C:\> sfc /verifyonly

  WINDOWS — DISM Repair
    C:\> DISM /Online /Cleanup-Image /ScanHealth
    C:\> DISM /Online /Cleanup-Image /CheckHealth
    C:\> DISM /Online /Cleanup-Image /RestoreHealth
    C:\> DISM /Online /Cleanup-Image /StartComponentCleanup

  WINDOWS — Boot Repair
    C:\> bootrec /fixmbr
    C:\> bootrec /fixboot
    C:\> bootrec /rebuildbcd
    C:\> bootsect /nt60 ALL /mbr

  WINDOWS — Reset Firewall
    C:\> netsh advfirewall reset

  WINDOWS — Reset TCP/IP Stack
    C:\> netsh int ip reset resetlog.txt
    C:\> netsh winsock reset catalog

  WINDOWS — Restore from VSS
    C:\> vssadmin list shadows
    C:\> mklink /D C:\\restore \\\\?\\GLOBALROOT\\Device\\HarddiskVolumeShadowCopy1\\

  WINDOWS — System Restore (CLI)
    PS C:\> Restore-Computer -RestorePoint <POINT_ID>

  WINDOWS — Re-enable Services
    C:\> sc config <SERVICE> start= auto
    C:\> sc start <SERVICE>

  WINDOWS — Rebuild from Image
    C:\> wbadmin get versions
    C:\> wbadmin start recovery \\
         -version:<BACKUP_VERSION> \\
         -items:<VOLUMES> -itemtype:volume

  LINUX — Fix broken packages
    # apt-get -f install
    # dpkg --configure -a

  LINUX — Rebuild package database
    # rpm --rebuilddb             (RedHat)
    # apt-get install --reinstall <PKG>

  LINUX — Restore from backup (rsync)
    # rsync -avz /backup/. /restore/.

  LINUX — Restore IPTables
    # iptables-restore < /etc/iptables/rules.v4

  LINUX — fsck repair
    # umount /dev/sdb1
    # fsck -y /dev/sdb1
    # fsck -t ext4 /dev/sda1 -y

  LINUX — Re-enable firewall
    # ufw enable
    # service iptables start

  LINUX — Re-lock user accounts
    # usermod -L <USER>
    # passwd -l <USER>
    # chage -E 1 <USER>

  LINUX — Force password change on next login
    # chage -d 0 <USER>"
}
