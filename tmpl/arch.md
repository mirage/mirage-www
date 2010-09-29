To build network servers in Mirage, you need to understand three concepts:

* *Concurrency* is handled using co-operative threads, which means that your application must explicitly yield control to other threads. These threads are very light-weight, and thus this model works well for parallel I/O.

* *Networking* traffic is fed to the application via [lens buffers](/code/len), which are data structures designed for zero-copy parsing and construction of wire traffic. Mirage provides several methods to make it easy to parse binary protocols (e.g. Ethernet, TCP/IP or BGP), text protocols (e.g. ABNF grammers for HTTP or IMAP), and data formats like XML or JSON.

* *Storage* is provided via an ORM extension which lets native OCaml types be saved and queried.  Some backends are relational ([SQLite](http://sqlite.org/)) and others purely functional with permanent history (e.g. the git or block-based backends).
