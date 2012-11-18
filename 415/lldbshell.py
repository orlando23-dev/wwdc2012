#!/usr/bin/python
import lldb
import commands
def ls_cmd(debugger, command, result, dict):
        shell_cmd = '/bin/ls %s' % command
        shell_result = commands.getoutput(shell_cmd)
        result.PutCString(shell_result)
