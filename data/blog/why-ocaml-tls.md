---
updated: 2015-06-26 14:00
authors:
- name: Amir Chaudhry
  uri: http://amirchaudhry.com
  email: amirmc@gmail.com
subject: Why OCaml-TLS?
permalink: why-ocaml-tls
---

TLS implementations have a history of security flaws, which are often the
result of implementation errors.  These security flaws stem from the
underlying challenges of interpreting ambiguous specifications, the
complexities of large APIs and code bases, and the use of unsafe programming
practices.

Re-engineering security-critical software allows the opportunity to use modern
approaches to prevent these recurring issues. Creating [the TLS stack in OCaml](https://github.com/mirleft/ocaml-tls)
offers a range of benefits, including: 

**Robust memory safety**: Lack of memory safety was the largest single source
of vulnerabilities in various TLS stacks throughout 2014, including
[Heartbleed (CVE-2014-0160)](http://heartbleed.com). OCaml-TLS avoids this
class of issues entirely due to OCaml's automatic memory management, safety
guarantees and the use of a pure-functional programming style.

**Improved certificate validation**: Implementation errors in other stacks
allowed validation to be skipped under certain conditions, leaving users
exposed (e.g.
[CVE-2014-0092](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2014-0092)).
In our TLS stack, we return errors explicitly as values and handle all
possible variants. The OCaml toolchain and compile-time checks ensure that
this has taken place.

**Mitigation of state machine errors**: Errors such as
[Apple's GoTo Fail (CVE-2014-1266)](https://gotofail.com) involved code being
skipped and a default 'success' value being returned, even though signatures
were never verified. Our approach encodes the state machine explicitly, while
state transitions default to failure. The code structure also makes clear the
need to consider preconditions.

**Elimination of downgrade attacks**: Legacy requirements forced other TLS
stacks to incorporate weaker 'EXPORT' encryption ciphers. Despite the
environment changing, this code still exists and leads to attacks such as
[FREAK (CVE-2015-0204)](https://freakattack.com) and
[Logjam (CVE-2015-4000)](https://weakdh.org). Our TLS server does not support
weaker EXPORT cipher suites so was never vulnerable to such attacks.
In addition our stack never supported SSLv3, which was known to be the cause of many vulnerabilities and is only now in the process of being deprecated ([RFC: 7568](https://tools.ietf.org/html/rfc7568)).


**Greatly reduced TCB**: The size of the trusted computing base (TCB) of a
system, measured in lines of code, is a widely accepted approximation of the
size of its attack surface.  Our secure Bitcoin Piñata, a unikernel built
using our TLS stack, is less than 4% the size of an equivalent, traditional
stack (102 kloc as opposed to 2560 kloc).

These are just some of the benefits of re-engineering critical software using
modern techniques.

