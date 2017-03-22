BaseXClient-Tcl
=====

[Tcl](http://www.tcl.tk/) client for [BaseX](http://basex.org/) database.
BaseX is a light-weight, high-performance and scalable XML Database engine and
XPath/XQuery 3.1 Processor, which includes full support for the W3C Update and
Full Text extensions.

The library consists of a single
[Tcl Module](http://tcl.tk/man/tcl8.6/TclCmd/tm.htm#M9) file, communicates with a BaseX database
by using the [BaseX Server Protocol](http://docs.basex.org/wiki/Server_Protocol).

This library requires Tcllib md5 package.

License
=====

MIT


Interface
=====

The library has 2 TclOO class, `Session` and `Query`.
`Session` is for creating a session, sending and executing commands and receiving results.
An inner `Query` class facilitates the binding of external variables and iterative query evaluation.


Examples
=====

Please check below files:

AddExample.tcl  
Example.tcl  
ExampleCreate.tcl  
QueryBindExample.tcl  
QueryExample.tcl
