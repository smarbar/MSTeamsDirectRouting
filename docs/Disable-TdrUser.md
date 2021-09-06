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

### EXAMPLE 1
```
Disable-TdrUser [-Username] name@domain.com
```
Disables EnterpriseVoice and HostedVoicemail on a user

## PARAMETERS

### -Username
Required. UserPrincipalName or LoginName of the Office365 User

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### System.String
## NOTES
This CmdLet can be used to disbale voice on a user

## RELATED LINKS

[https://github.com/smarbar/MSTeamsDirectRouting/tree/main/docs/Disable-TdrUser.md](https://github.com/smarbar/MSTeamsDirectRouting/tree/main/docs/Disable-TdrUser.md)

[https://github.com/smarbar/MSTeamsDirectRouting/tree/main/docs](https://github.com/smarbar/MSTeamsDirectRouting/tree/main/docs)