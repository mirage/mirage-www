In this post I introduce [HTCaML](http://www.github.com/samoht/htcaml)
and explain how to use it to generate static HTML from within OCaml applications. It consists of:

* a quotation mechanism to embed XML into an OCaml program.
* a syntax extension to auto-generate boilerplate HTML definitions from OCaml type definitions.

!!HTML quotations

Let us first focus on the quotation mechanism. This part is quite
similar to the syntax extension provided by
[Eliom](http://ocsigen.org/eliom/manual/1.3.0/), but exposed as
explicit `<:html< ... >>` quotations. This lets us compose HTCaML with
other language quotations (such as CSS) in the same file.

Let us start with an example. We would like to display a list of tweets
stored locally. As for any OCaml program, we need to start thinking first
about the data structures to use. So let us define one:

{{
type author = {
 name : string;
 link : string;
}
}}

for the `author` type and:

{{
type tweet = {
  author = author;
  date = Date.t;
  contents = Html.t
}
}}

for the `tweet` type. We assume here that we have already defined in our
code a module `Date` which manipulates date formats. `Html.t` is
part of the HTCaML library and is the type of HTML fragments.

We can now define the functions converting any value of type `tweet`
into an HTML fragment. Let us start with `val html_of_author : author -> Html.t`:

{{
let html_of_author a =
   <:html<
      <a href=$str:a.link$>$str:name$</a>
   >>
}}

Fragments of code written between `$` are called "antiquotations", and
are valid OCaml code not interpreted by the HTML parser; the
(optional) prefix first of the antiquotation is a hint to the compiler
to understand the type of the value returned by the antiquotation. The
code above will automatically be expanded by `camlp4` into:

{{
let html_of_author a =
   Html.Tag ("a",
     Html.Prop(href,
       Html.String a.link),
     Html.String name)
}}

Next, we can write the code for `val html_of_tweet : tweet -> Html.t`:

{{
let html_of_tweet t =
   <:html<
      <div class="tweet">
        <div class="author">$html_of_author t.author$</div>
        <div class="date">$Date.html_of_date t.date$</div>
        <div class="contents">$t.contents$</div>
      </div>
   >>
}}

Note that we do not need to add a prefix to the antiquotations here as
the `html_of_*` functions already return a value of type `Html.t`, and so
no translation from other types (e.g. a `string`) is required.

Then, using `val Html.to_string : Html.t -> string`, it is
straightforward to process a list of tweet values in order to generate
a static HTML page:

{{
let process tweets =
    let html = <:html<
      <html>
        <head>
          <link rel="stylesheet" type="text/css" href="style.css"/>
        </head>
        <body>
          My collection of tweets :
          $list:List.map html_of_tweet tweets$
        </body>
      </html>
    >> in
    let chan = open_out "tweets.html" in
    output_string chan (Html.to_string html);
    close_out chan
}}

Finally, we can use [CaSS](http://www.github.com/samoht/cass) to produce
a very simple CSS files. CaSS provides CSS quotations to convert CSS
fragments into an OCaml program:

{{
let () =
  let color = <:css< black >> in
  let css  = <:css<
    .tweet           { background: yellow; color: $color$; }
    .tweet .author   { display: inline; }
    .tweet .date     { display: inline; }
    .tweet .contents { font-style: italic; }
  >> in
  let chan = open_out "style.css" in
  output_string chan (Css.to_string css);
  close_out chan
}}

!!HTML Generator
 
Some of the OCaml code we wrote in the last section is quite tedious
to write. Let us consider `html_of_tweet` again:

{{
let html_of_tweet t =
   <:html<
      <div class="tweet">
        <div class="author">$html_of_author t.author$</div>
        <div class="date">$Date.html_of_date t.date$</div>
        <div class="contents">$t.contents$</div>
      </div>
   >>
}}

To write this code fragment, we had to reason by
induction on the type structure of `tweet`. So this piece of code can
be generated automatically, given a way to obtain a dynamic representation of the
type structure. That is exactly what the
[DynType](http://www.github.com/samoht/dyntype) library does!
Using DynType, HTCaML can auto-generate `html_of_t` when the type definition of
`t` is annotated by the keywords `with html`. However, we still want
to be able to manually write the translation to HTML, as for the
`author` type above.

So we can rewrite the previous example:

{{
type author = {
 name : string;
 link : string;
}

let html_of_author a =
   <:html<
      <a href=$str:a.link$>$str:name$</a>
   >>

type tweet = {
  author = author;
  date = Date.t;
  contents = Html.t
} with html
}}

And `html_of_tweet` will pick the right definition of `html_of_author`.
