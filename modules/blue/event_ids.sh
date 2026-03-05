#!/usr/bin/env bash
# modules/blue/event_ids.sh

blue_event_ids() {
    show_page "🔑 Windows Event ID Reference" \
"═══════════════════════════════════════════════════════════════
  Windows Event ID Reference                           [BLUE]
═══════════════════════════════════════════════════════════════

  AUTHENTICATION EVENTS
  ─────────────────────
  4624  Successful logon
  4625  Failed logon
  4634  Account logoff
  4647  User initiated logoff
  4648  Logon using explicit credentials (runas)
  4649  Replay attack detected
  4672  Special privileges assigned to new logon (admin)
  4675  SIDs were filtered

  ACCOUNT MANAGEMENT
  ──────────────────
  4720  User account created
  4722  User account enabled
  4723  Password change attempt
  4724  Password reset attempt
  4725  User account disabled
  4726  User account deleted
  4728  Member added to global group
  4732  Member added to local group
  4735  Local group changed
  4738  User account changed
  4740  User account locked out
  4756  Member added to universal group

  LOGON TYPES
  ───────────
  2   Interactive       (physical logon)
  3   Network           (net use, mapped drive)
  4   Batch             (scheduled tasks)
  5   Service           (service started)
  7   Unlock            (screen unlock)
  8   NetworkCleartext  (IIS basic auth)
  9   NewCredentials    (runas with /netonly)
  10  RemoteInteractive (RDP)
  11  CachedInteractive (cached creds)

  POLICY / AUDIT CHANGES
  ──────────────────────
  4616  System time changed
  4657  Registry value modified
  4663  Object access attempted
  4670  Permissions on object changed
  4698  Scheduled task created
  4699  Scheduled task deleted
  4700  Scheduled task enabled
  4701  Scheduled task disabled
  4702  Scheduled task updated
  4706  New trust to domain created
  4719  System audit policy changed

  KERBEROS
  ────────
  4768  Kerberos TGT request
  4769  Kerberos service ticket request
  4770  Kerberos TGT renewed
  4771  Kerberos pre-auth failed
  4772  Kerberos auth ticket failure
  4776  NTLM authentication (DC)
  4777  Domain controller failed to validate credentials

  PROCESS / EXECUTION
  ───────────────────
  4688  Process created (inc. command line if enabled)
  4689  Process ended
  4697  Service installed in system
  7034  Service crashed
  7035  Service start/stop control sent
  7036  Service started or stopped
  7040  Service start type changed
  7045  New service installed

  NETWORK SHARE
  ─────────────
  5140  Network share accessed
  5142  Network share added
  5143  Network share changed
  5144  Network share deleted
  5145  Share access checked
  5156  Windows Filtering Platform allowed connection
  5157  Windows Filtering Platform blocked connection
  5158  Bind to local port
  5447  WFP filter changed

  POWERSHELL / SCRIPTS
  ────────────────────
  4103  PS module logging
  4104  PS scriptblock logging (most useful)
  4105  PS command start
  4106  PS command end
  400   PS engine started
  600   PS provider started

  QUERY TIPS (wevtutil)
  ─────────────────────
  # wevtutil qe Security /q:\"*[System[(EventID=4624)]]\" /c:50 /rd:true /f:text
  # wevtutil qe Security /q:\"*[System[(EventID=4625)]]\" /f:text
  # Get-EventLog Security | ? {\\$_.EventId -in 4720,4726} | Select *"
}
