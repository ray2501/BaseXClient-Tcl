#!/usr/bin/tclsh
#
# This example shows how database commands can be executed.
#

package require BaseXClient

set client [Session new localhost 1984 admin admin]
if {[catch {$client connect}]!=0} {
    puts "Connect fail."
    exit
}

# execute method returns a list: {result}{info}
set result [$client execute "xquery 1 to 10"]
puts [lindex $result 0]
$client close
