# Connect-Tdr

## SYNOPSIS
Connects to Azure AD and Teams services using the AzureAD and Microsoft Teams Modules

## SYNTAX

```
Connect-Tdr [<CommonParameters>]
```

## DESCRIPTION
Connects and conducts various tests to make sure the necessary Powershell version and dependant modules are installed as well as the correct role is assigned to the logged in user

## EXAMPLES

### EXAMPLE 1
```
Connect-Tdr
```

Creates a session to AzureAD with a seperate pop up window promting for credentials
Creates a session to MicrosoftTeams prompting for selection of existing loed in sessions

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### System.String
## NOTES
This CmdLet can be used to establish a session to: AzureAD and MicrosoftTeams
Each Service has different requirements for connection, query (Get-CmdLets), and action (other CmdLets)
For AzureAD, no particular role is needed for connection and query. Get-CmdLets are available without an Admin-role.
For MicrosoftTeams, Teams Administrator Role is required

## RELATED LINKS

[https://github.com/smarbar/MSTeamsDirectRouting/tree/main/docs/Connect-Tdr.md](https://github.com/smarbar/MSTeamsDirectRouting/tree/main/docs/Connect-Tdr.md)

[https://github.com/smarbar/MSTeamsDirectRouting/tree/main/docs](https://github.com/smarbar/MSTeamsDirectRouting/tree/main/docs)