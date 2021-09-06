---
external help file: MSTeamsDirectRouting-help.xml
Module Name: MSTeamsDirectRouting
online version:
schema: 2.0.0
---

# Disable-TdrUser

## SYNOPSIS
Disbale voice on a user

## SYNTAX

```
Disable-TdrUser [-Username] <String> [<CommonParameters>]
```

## DESCRIPTION
Disbales EnterpriseVoice and HostedVoicemail on a user

## EXAMPLES

### Example 1
```powershell
PS C:\> Disable-TdrUser [-Username] name@domain.com
```

Disables EnterpriseVoice and HostedVoicemail on a user

## PARAMETERS

### -Username
Required. UserPrincipalName or LoginName of the Office365 User

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### System.Object
## NOTES
This CmdLet can be used to disbale voice on a user

## RELATED LINKS

[https://github.com/smarbar/MSTeamsDirectRouting/tree/main/docs/Disable-TdrUser.md](https://github.com/smarbar/MSTeamsDirectRouting/tree/main/docs/Disable-TdrUser.md)

[https://github.com/smarbar/MSTeamsDirectRouting/tree/main/docs](https://github.com/smarbar/MSTeamsDirectRouting/tree/main/docs)