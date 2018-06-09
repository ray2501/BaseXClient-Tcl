#!/usr/bin/tclsh
#
# Query example
#

package require BaseXClient

set client [Session new localhost 1984 admin admin]
if {[catch {$client connect}]!=0} {
    puts "Connect fail."
    exit
}

set input {for $i in 1 to 10 return <xml>Text { $i }</xml>}
set query [$client query $input]
set result [$query results]

foreach r $result {
    puts $r
}

$query close
$client close
