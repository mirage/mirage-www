This page records API changes that require existing code to be updated.

### 2015-06-18: HTTP servers with Mirage > 2.5

Before, you would specify your server's address in the `config.ml`:

    let server =
      http_server (`TCP (`Port 8080)) (conduit_direct (stack default_console))

and then use it in your `unikernel.ml` as:

    let start http =
      ...
      http (H.make ~callback ~conn_closed ())

With mirage > 2.5, the address argument is no longer present and you will get this error:

    Error: This function has type
             Mirage.conduit Mirage.impl -> Mirage.http Mirage.impl
           It is applied to too many arguments; maybe you forgot a `;'.

To update, change `config.ml` to:

    let server =
      http_server (conduit_direct (stack default_console))

and move the address to your `unikernel.ml`:

    let start http =
      ...
      http (`TCP 8080) (H.make ~callback ~conn_closed ())

Note that the `Port` tag has also been removed.

This change was needed to support TLS servers, since TLS configuration (keys and certificates) is more complex and cannot be declared in the `config.ml`.

Commit: <https://github.com/mirage/mirage/commit/56e500d4210bf7fdcdc296f3c34ce13c9f57cdf5>
