---
external help file: MSTeamsDirectRouting-help.xml
Module Name: MSTeamsDirectRouting
online version:
schema: 2.0.0
---

# Disconnect-Tdr

## SYNOPSIS
Disconnect both AzureAD and Teams sessions

## SYNTAX

```
Disconnect-Tdr [<CommonParameters>]
```

## DESCRIPTION
Disconnects any open AzureAD and Microsoft Teams Sessions

## EXAMPLES

### Example 1
```powershell
PS C:\> Disconnect-Tdr
```

Disconnects from AzureAD, MicrosoftTeams
Errors and Warnings are suppressed as no verification of existing sessions is undertaken

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES
This CmdLet can be used to disconnect the sessions to: AzureAD and MicrosoftTeams

## RELATED LINKS

[https://github.com/smarbar/MSTeamsDirectRouting/tree/main/docs/Disconnect-Tdr.md](https://github.com/smarbar/MSTeamsDirectRouting/tree/main/docs/Disconnect-Tdr.md)

[https://github.com/smarbar/MSTeamsDirectRouting/tree/main/docs](https://github.com/smarbar/MSTeamsDirectRouting/tree/main/docs)