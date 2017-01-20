#
# Tcl client for BaseX database.
# Works with BaseX 7.0 and later
#
# (C) Danilo Chang 2017, MIT License
#
#

package require Tcl 8.6
package require TclOO
package require md5

package provide BaseXClient 0.1

oo::class create Session {
    variable host
    variable port
    variable username
    variable password
    variable channel
    variable state

    constructor {HOST PORT USERNAME PASSWORD} {
        set host $HOST
        set port $PORT
        set username $USERNAME
        set password $PASSWORD
        set state 0
        set channel 0
    }

    destructor {
    }

    method checkread {} {
        fileevent $channel readable {}
        set [namespace current]::state 1
    }

    method connect {} {
        variable result
        variable index
        variable realm
        variable nonce
        variable ts

        if {[catch {set channel [socket $host $port]}]} {
            return -code 1
        }
        fconfigure $channel -blocking 0 -buffering none -encoding binary \
            -translation binary

        fileevent $channel readable "[self] checkread"
        vwait [namespace current]::state
        set result [chan read -nonewline $channel]
        set index [string first ":" $result]
        if {$index != -1} {
            # Digest authentication is used since Version 8.0
            set realm [string range $result 0 $index-1]
            set nonce [string range $result $index+1 [string length $result]-2]
            set ts [string tolower [::md5::md5 -hex "$username:$realm:$password"]]
            append ts $nonce
        } else {
            set ts [string tolower [::md5::md5 -hex $password]]
            append ts $result
        }

        # Write username
        my send $username

        # Write digest
        set digest [string tolower [::md5::md5 -hex $ts]]
        my send $digest

        if {[my ok] == 1} {
            return -code 0
        } else {
            return -code 1
        }
    }

    method execute {COMMAND} {
        my send $COMMAND

        set result [my readString]
        set info [my readString]

        if {[my ok] == 0} {
            return -code 1 $info
        }

        return -code 0 [list $result $info]
    }

    method create {NAME INPUT} {
        variable result

        if {[catch {set result [my sendInput 8 $NAME $INPUT]} errMsg] != 0} {
            return -code 1 $errMsg
        }

        return -code 0 $result
    }

    method add {PATH INPUT} {
        variable result

        if {[catch {set result [my sendInput 9 $PATH $INPUT]} errMsg] != 0} {
            return -code 1 $errMsg
        }

        return -code 0 $result
    }

    method replace {PATH INPUT} {
        variable result

        if {[catch {set result [my sendInput 12 $PATH $INPUT]} errMsg] != 0} {
            return -code 1 $errMsg
        }

        return -code 0 $result
    }

    method store {PATH INPUT} {
        variable result

        if {[catch {set result [my sendInput 13 $PATH $INPUT]} errMsg] != 0} {
            return -code 1 $errMsg
        }

        return -code 0 $result
    }

    method query {QUERYSTRING} {
        set query [Query new [self] $QUERYSTRING]
        return $query
    }

    method close {} {
        my send "exit"
        chan close $channel

        my destroy
    }

    method ok {} {
        variable code

        fileevent $channel readable "[self] checkread"
        vwait [namespace current]::state

        set code [chan read $channel 1]
        if {$code != [format %c 0]} {
            return 0
        } else {
            return 1
        }
    }

    method readString {} {
        variable buffer

        fileevent $channel readable "[self] checkread"
        vwait [namespace current]::state

        set buffer ""
        while {[catch {set result [chan read $channel 1]}] == 0} {
            if {$result != [format %c 0]} {
                append buffer $result
            } else {
                break;
            }
        }

        return $buffer
    }

    method send {COMMAND} {
        puts -nonewline $channel $COMMAND
        puts -nonewline $channel [format %c 0]
    }

    method sendInput {CODE STRING INPUT} {
        puts -nonewline $channel [format %c $CODE]
        puts -nonewline $channel $STRING
        puts -nonewline $channel [format %c 0]

        puts -nonewline $channel $INPUT
        puts -nonewline $channel [format %c 0]

        set info [my readString]
        if {[my ok] == 0} {
            return -code 1 $info
        }

        return -code 0 $info
    }
}


oo::class create Query {
    variable session
    variable querystring
    variable id

    constructor {SESSION QUERYSTRING} {
        set session $SESSION
        set querystring $QUERYSTRING

        if {[catch {set id [my exec [format %c 0] $querystring]}] != 0} {
            error "create object fail."
        }
    }

    destructor {
    }

    method results {} {
        variable args
        variable recvString
        variable format4
        variable format0
        variable result

        set format4 [format %c 4]
        set format0 [format %c 0]
        $session send "$format4$id$format0"

        set result [list]

        while {![$session ok]} {
            set recvString [$session readString]
            lappend result $recvString
        }

        if {[$session ok] == 0} {
            set recvString [$session readString]
            return -code 1 $recvString
        }

        return -code 0 $result
    }

    method bind {NAME VALUE {TYPE ""}} {
        variable format0
        variable commandargs

        set format0 [format %c 0]
        set commandargs "$id$format0$NAME$format0$VALUE$format0$TYPE"
        my exec [format %c 3] $commandargs
    }

    method context {VALUE {TYPE ""}} {
        variable format0
        variable commandargs

        set format0 [format %c 0]
        set commandargs "$id$format0$VALUE$format0$TYPE"
        my exec [format %c 14] $commandargs
    }

    method execute {} {
        return [my exec [format %c 5] $id]
    }

    method info {} {
        return [my exec [format %c 6] $id]
    }

    method options {} {
        return [my exec [format %c 7] $id]
    }

    method close {} {
        my exec [format %c 2] $id
        my destroy
    }

    method exec {COMMAND ARGS} {
        variable sendString
        variable recvString

        set sendString "$COMMAND$ARGS"
        $session send $sendString

        set recvString [$session readString]

        if {[$session ok] == 0} {
            set recvString [$session readString]
            return -code 1 $recvString
        }

        return -code 0 $recvString
    }
}
