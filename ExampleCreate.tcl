#!/usr/bin/tclsh
#
# This example shows how new databases can be created.
#

package require BaseXClient

set client [Session new localhost 1984 admin admin]
if {[catch {$client connect}]!=0} {
    puts "Connect fail."
    exit
}

if {[catch {set info [$client create "database" "<x>Hello World!</x>"]}]==0} {
   puts "create: $info"
}

# execute method returns a list: {result}{info}
set result [$client execute "xquery /"]
puts [lindex $result 0]

$client execute "drop db database"
$client close
