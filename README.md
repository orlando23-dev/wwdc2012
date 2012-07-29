wwdc2012
========

wwdc2012 full session analysis and code

1, SSH key configuration on github.com 
reference - https://help.github.com/articles/generating-ssh-keys
github.com help - https://help.github.com

**** local video/pdf - /Users/llv22/Movies/WWDC 2012 Session Videos **** 
**** general preparation ****
--> GITIGNORE PREPARATION
Reason: As xcode store local user/workspace setting into <project>.xcodeproj, for some cases, for instance, non-synchronized breakpoint in server back to client case, the invalid breakpoints may lead to xcode layout crash, when click to breakpoints subwindow
Operation: 
ngs-MacBook-Pro:wwdc2012 llv22$ cat .gitignore
# ignored files in workspace
215/215.xcodeproj/project.xcworkspace/xcuserdata/ #ignore xcuserdata folder
215/215.xcodeproj/project.xcworkspace/xcuserdata/llv22.xcuserdatad/ # UserInterfaceState.xcuserstate in xcuserdatad should be ignored for breakpoints

2, Session 215 - Text and Linguistic Analysis
author : Douglas Davidson
