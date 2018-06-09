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

# execute method returns a list: {result}{info}
set info [$client execute "create db database"]
puts "create db: [lindex $info 1]"

set info [$client add "world/World.xml" "<x>Hello World!</x>"]
puts "add world/World.xml: $info"

set info [$client add "Universe.xml" "<x>Hello Universe!</x>"]
puts "add Universe.xml: $info"

set result [$client execute "xquery /"]
puts [lindex $result 0]

$client execute "drop db database"
$client close
