let mk_uri x = Uri.of_string ("http://openmirage.org/" ^ x)
let mk_uri_string x = Uri.to_string (mk_uri x)
