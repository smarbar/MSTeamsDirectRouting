[![Build Status](https://smarbar.visualstudio.com/MSTeamsDirectRouting/_apis/build/status/MSTeamsDirectRouting-CI?branchName=main)](https://smarbar.visualstudio.com/MSTeamsDirectRouting/_build/latest?definitionId=1&branchName=main)
# MSTeamsDirectRouting - Helps to create and administer Teams for Direct Routing

This is the home for `MSTeamsDirectRouting`, a module for Creating and Administering Teams Direct Routing

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/smarbar/MSTeamsDirectRouting/blob/main/LICENSE)
[![Documentation - GitHub](https://img.shields.io/badge/Documentation-TeamsFunctions-blue.svg)](https://github.com/smarbar/MSTeamsDirectRouting/tree/main/docs)
[![PowerShell Gallery - TeamsFunctions](https://img.shields.io/badge/PowerShell%20Gallery-TeamsFunctions-blue.svg)](https://www.powershellgallery.com/packages/MSTeamsDirectRouting)
[![Minimum Supported PowerShell Version](https://img.shields.io/badge/PowerShell-5.1-blue.svg)](https://github.com/smarbar/MSTeamsDirectRouting)
<a href="https://www.repostatus.org/#wip"><img src="https://www.repostatus.org/badges/latest/wip.svg" alt="Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public." /></a>
<!-- <a href="https://www.repostatus.org/#active"><img src="https://www.repostatus.org/badges/latest/active.svg" alt="Project Status: Active – The project has reached a stable, usable state and is being actively developed." /></a> -->


## Overview

MSTeamsDirectRouting is a module to make the initial setup for Teams Direct Routing easier with an ITSP. It can be used to create the base routing inftrastructure (PSTNUsage, Route Policy & Voice Routing Policy) needed for direct routing. Individually or bulk enable users for Voice and assign the newly created policies to that user.

It is very much a work in progress with new features being added all the time.

### Installation

```powershell
# Release
Install-Module -Name MSTeamsDirectRouting
```

### Documentation

- All help is available in [/docs](/docs)
- External Help is available as XML
- Markdown files for all CmdLets created automatically with PlatyPS and updated with each Version