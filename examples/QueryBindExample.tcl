#!/usr/bin/tclsh
#
# This example shows how external variables can be bound to XQuery expressions.
#

package require BaseXClient

set client [Session new localhost 1984 admin admin]
if {[catch {$client connect}]!=0} {
    puts "Connect fail."
    exit
}

set input {declare variable $name external; for $i in 1 to 10 return element { $name } { $i }}
set query [$client query $input]

$query bind "name" "number"
puts [$query execute]

$query close
$client close
