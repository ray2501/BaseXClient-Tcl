package require Tcl 8.6
package require tcltest 2.2

tcl::tm::path add [file join [file dirname [info script]] .. ]
package require BaseXClient

tcltest::configure {*}$argv -singleproc 1 -testdir [file dir [info script]]

tcltest::runAllTests

