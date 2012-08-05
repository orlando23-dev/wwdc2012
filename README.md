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
REMOVE TRACK FILE if exists - Dings-MacBook-Pro:wwdc2012 llv22$ git rm -rf 215/215.xcodeproj/xcuserdata/

Modification of .gitignore - 
echo xcuserdata/ >> .gitignore
git add .gitignore
--> synchronization to server

Reference - /Users/llv22/Documents/i058959_dev/01_git/01_guide/progit_en.pdf
Page 18 -> .gitignore file pattern

ISSUE sovling : Your branch is ahead of 'origin/master' by 1 commit.
Operation : git fetch / git pull sometimes not write/overwrite
Reference : http://stackoverflow.com/questions/9050978/your-branch-is-ahead-of-origin-master-by-1-commit-on-explicit-push

2, Session 215 - Text and Linguistic Analysis
author : Douglas Davidson
implementation : in 215
furthermore : Jennifer Moore in Natural Languages Group [39:22, 12 minutes]
implementation : in 215a [later for 2/3 days]

3, Session 216 - Advanced Appearance Customization on iOS
author : Jacob Xiao
