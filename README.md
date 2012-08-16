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
follow-up : <this required iOS6.0 and XCode 4.5, will be implemented in virtual 10.8 preview later>

4, Session 220 - Keyboard input on iOS
author : Justin Garcia
implementation : in 220

5, Session 210 - Accessiblity for iOS
author : Chris Fleizach
impelmentation : in 210 demo, here just, attached the existing source code from wwdc demo here - 210 - Accessibility for iOS. [take care, chris forget to add CALayer definetion here, so during compilation, you may meet with issue. none of member of CALayer not visualable. see, http://stackoverflow.com/questions/9829371/property-cannot-be-found-on-forward-class-object]
pre-requisitive : in xcode 4.5, with preview version of ***iOS 6.0***

6, Session 223 - Enhancing User Experience with Scroll Views [based on 220]

7, Session 405 - Modern Objective-C
author : Patrick C. Beard
implementation : none - just theory for update
