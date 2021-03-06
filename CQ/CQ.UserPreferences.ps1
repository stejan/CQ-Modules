﻿# ---------------------------------------------------------------------------
# You can override individual preferences by passing a hashtable with just those
# preference defined as shown below:
#
#     Import-Module Pscx -arg @{ModulesToImport = @{Prompt = $true}}
#
# Any value not specified will be retrieved from the default preferences built
# into the PSCX DLL.
#
# If you have a sufficiently large number of altered preferences, copy this file,
# modify it and pass the path to your preferences file to Import-Module e.g.:
#
#     Import-Module Pscx -arg "$(Split-Path $profile -parent)\Pscx.UserPreferences.ps1"
#
# ---------------------------------------------------------------------------
$CQ = @{
    Version = 5.4
    
    ShowModuleLoadDetails = $true    # Display module load details during Import-Module
    
    SmtpFrom = $null                  # Specify a default from email address.
    SmtpHost = $null                  # Specify a default SMTP server.
    SmtpPort = $null                  # Specify a default port number if not specified port 25 is used.

    host   = "localhost"            # Specify a default CQ server.
    port   = "4502"                 # Specify a default port number if not specified port 4502 is used.
    user   = "admin"                # Specify a default CQ user.
    pwd    = "admin"                # Specify a default CQ password.
    workspace = "crx.default"       # Specify a default CQ workspace.
    
    loginFile = "login.txt"
    progressFile = "progress.txt"

	ModulesToImport = @{
        Page            = $true;
        SlingFolder     = $true;
        Access          = $true;
        Content         = $true;
        Tag             = $true;
        Backup          = $true;
    }
}