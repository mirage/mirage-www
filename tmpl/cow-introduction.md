Writing web-applications requires a lots of skills. First of all, you need to master
numerous description and programming languages like [HTML](http://en.wikipedia.org/wiki/HTML),
[CSS](http://en.wikipedia.org/wiki/Cascading_Style_Sheets), [XML](http://en.wikipedia.org/wiki/XML),
[JSON](http://en.wikipedia.org/wiki/JSON),[markdown](http://en.wikipedia.org/wiki/Markdown),
[JavaScript](http://en.wikipedia.org/wiki/JavaScript), [SQL](http://en.wikipedia.org/wiki/SQL), ...
You also need to master the art of of plumbing : translating concepts from
one language to an other is tedious and error-prone code; it is this very hard to avoid
security issues as injection, cross-scripting, ... To fix these issues, some new languages
such as [HOP](http://hop.inria.fr/), [OPA](https://www.mlstate.com/),... have been proposed
recently.

In this post, I will describe the library we developed for OCaml to solve these problems. We coined
that library [CoW](http://www.github.com/samoht/mirage/lib/cow), for __Caml on web__.

!!!Context

Cow generalizes what we have discussed about [HTCaML](blog/introduction-to-htcaml). It is
composed of two main parts.

* First, Cow enables using the web languages as Embedded DSL into OCaml : it offers
a quotation mechanism which compiles to pure OCaml -- anti-quotations can then be used
as a template mechanism to call back some OCaml code.

* Second, Cow relies on type-driven code generation. Using an camlp4 syntax extension to
annotate type declarations, it is possible to automatically generate boiler-plate OCaml code
to translate data from one web language to another. Moreover, as we reason by induction,
it is possible to mix hand-written and generated code to deal more easily with special-cases.

In Cow, most of the work is done at pre-processing time, so there is no hidden runtime costs.

<img src="/graphics/cow-schema.png" alt="schema" width="50%"/>

!!!Embedded Domain Specific Language

!!!!Quotations in Camlp4

Camlp4 quotations are an easy way to manipulate OCaml AST. Quotations are named, and they are enclosed
between `<:name< ... >>`. For each name, corresponds a dedicated parser, so inside quotations, you are
not writing OCaml code anymore but things that the associated parser will parse. You can come back to
the OCaml world using `$...$` inside quotations. For example, camlp4 defines, for each node of the OCaml
AST a quotation whose name is the node kind and which is parsing OCaml fragment of this kind :

{{
let x = <:expr< Random.int 10 >>
let e = <:expr< 1 + $x$ >>
let t = <:ctyp< int list >>
}}

instead of the more tedious :

{{
let x =
  Ast.ExApp (_loc,
    (Ast.ExId (_loc,
      (Ast.IdAcc (_loc,
        (Ast.IdUid (_loc, "Random")),
        (Ast.IdLid (_loc, "int")))))),
    (Ast.ExInt (_loc, "10")))
  
let e =
  Ast.ExApp (_loc,
    (Ast.ExApp (_loc,
      (Ast.ExId (_loc,
        (Ast.IdLid (_loc, "+")))),
          (Ast.ExInt (_loc, "1")))),
    x)

let t =
  Ast.TyApp (_loc,
    (Ast.TyId (_loc,
      (Ast.IdLid (_loc, "int")))),
        (Ast.TyId (_loc,
          (Ast.IdLid (_loc, "list")))))
}}

!!!!Quotations in Cow

In Cow, each web language has is own quotation. Inside a quotation, the user
can write any valid code of the embedded language, and use anti-quotations to call
back some OCaml code. By default, values produced by anti-quotations should be of
the same type than the quotations they are embedded into. For example, for HTML:

{{
let world : Html.t = <:html< "World" >>
let html = <:html< <h1>Hello $world$!</h1> >>
}}

Here, quotations will be expanded to values of type `Html.t` (the type will be enforced
by the quotation expander, so the type constraint are not necessary), and `$world$` makes
the assumption than `home` is of type `Html.t` as well; this will be checked at compile-time,
after the pre-processing step.

It is also possible to give some hints to the quotation expander to tell him what is the 
expected type of a given anti-quotation; in this case, the expander will introduce the right
casts in the generated code. This hints appears as prefix of the anti-quotations; the usual
ones are `$str:...$ for strings, $int:...$ and $flo:...$ for numerals and $list:...$ for lists.
For example, the preceding example should be rewritten as :

{{
let world = "world"
let html = <:html< <h1>Hello $str:world$!</h1> >>
}}

It is possible to use different quotations in the same file :

{{
let css = : Css.t = <:css<
  h1 $tag$ {
    font-style: bold;
    $Css.rounded_corners$;
  } >>

let xml : Xml.t =
  <:xml< <book><title>foo</title></book> >>

let js : Javascript.t =
  <:js< document.write("This is my first JavaScript!"); >>

let js2 : Javascript.t =
  <:camlscript< List.iter print_int [1;2;3] >>
}}

The `<:js< >>` and `<:camlscript< >>` quotations are not yet available in Cow, but will be integrated
in next releases; `js` uses Jake Donham's [ocamljs](https://github.com/jaked/ocamljs) and an early prototype
of `camlscript` is available [on my gihtub account](https://github.com/samoht/camlscript).


!!!Type-driven code generation

!!!!Motivations

In ML, we rely on the type-inferrer/checker as much as possible. Usually :

* types come first; and then
* functions which read/process/create values of these types come later.

This is because it is very cheap and easy to encode part of the problem/algorithm in
the types and to reason on induction on them:

* the language of types is expressive (product types, sum types, objects, type variables, ...) ;
* the language of types is concise;
* all the complex types are inferred.

So the idea is to use normal OCaml types in our programs and let Cow translates __automatically__
these types in the EDSL web languages. We already described a similar approach to automatically 
[persist ML values](http://gazagnaire.org/pub/GM10.pd).

!!!!An example

Let's try to create a web-page containing some [tweets](http://twitter.com) using quotations only.

First of all, let us define the types :

{{
type user = {
  id_str      : string;
  screen_name : string;
}

type status = {
  id   : int;
  user : user;
  text : string;
}
}}

Then let us reason by induction on the types.

For user :

{{
let html_of_user u = <:html<
  <div class=id_str>$str:u.id_str$</div>
  <div class=screen_name>$str:u.screen_name$</div>
>>

let css_of_user = <:css<
  .id_str { display: none; }
  .screen_name { display: inline; color: blue; }
>>
}}

For status :

{{
let html_of_status s = <:html
  <div class=id>$int:s.id$</div>
  <div class=user>$html_of_user s.u$</div>
  <div class=text>$str:s.text$</div>
>>

let css_of_status = <:css<
  .id { display: none; }
  .user $css_of_user$;
  .text { color: grey; }
>>
}}

The coding style is nice because we can write HTML and CSS fragments generator close
to where the type is defined - this encourage modular style of coding which is a good
engineering practice. However, some of the code written to generate the HTML fragments
are quite repetitive and tedious to write. Fortunately, Cow can inductively generate code
based on annotated type definitions. Hence, the `html_of_user` and `html_of_status`
functions can be automatically generated by adding `with html` to type definitions :

{{
type user = {
  id_str      : string;
  screen_name : string;
} with html

type status = {
  id   : int;
  user : user;
  text : string;
} with html
}}

However, the `css_of_*` values are very application specific and thus, there it seems difficult
to add some code generation for CSS. However, it may be possible to generate a CSS validator to
check that the CSS fragment generated for a type does not define classes which are not defined 
in the type (will surely be present in a next version of Cow).

!!!!More code generation

So now, what to do if we want to use twitter API to read tweets ? Twitter API uses JSON, so most of the
existing twitter API for OCaml use hand-written JSON un-marshaler, and then look into association
lists to build back the ML object (like [ocamltitter](https://github.com/yoshihiro503/ocamltter)
or [ocaml-twitterstream](https://github.com/mariusaeriksen/ocaml-twitterstream). In Cow, we do like
[this](https://www.github.com/samoht/mirage/lib/cow/lib/twitter.ml) :

{{
type user = {
  id_str      : string;
  screen_name : string;
} with json

type status = {
  id   : int;
  user : user;
  text : string;
} with json
}}

The `type t = [..] with json` will __automatically__ generate :

{{
val t_of_user : t -> Json.t
val user_of_t : Json.t -> t
}}

It is possible to combine multiple code generator by separating the annotations with a comma, as
`type t = [..] with html,json`. It would be also be possible to use Cow with [ORM](https://www.github.com/mirage/orm)
to persist easily typed value with SQLite3.

!!!!Mixing generated and hand-written code

Manual and automatic code generation can be easily mixed. Indeed, the code which are generated call by
induction the function whose name is built from its compound names; thus, this function has to exist
in the current scope - no matter it is manually written or automatically generated by a type annotation.

A good example of mixing automatically generated and manually written code is the
[bindings](http://www.github.com/samoht/mirage/lib/cow/lib/atom.ml) to
[Atom](http://en.wikipedia.org/wiki/Atom_%28standard%29) for blog syndication. Indeed, for is some very
specific attributes names to insert for the content part of the message which cannot be auto-generated :

{{
type meta = [..] with xml

type content = Xml.t

let xml_of_content c = <:xml<
  <content type="xhtml">
    <xhtml:div xmlns:xhtml="http://www.w3.org/1999/xhtml">
      $c$
    </xhtml:div>
  </content>
>>

type entry = {
  entry   : meta;
  summary : string option;
  content : content;
} with xml

type feed = {
  feed    : meta;
  entries : entry list;
}

let xml_of_feed f = <:xml<
  <feed xmlns="http://www.w3.org/2005/Atom">
    $xml_of_meta f.feed$
    $list:List.map xml_of_entry f.entries$
  </feed>
>>
}}

!!!Status

To conclude, a table to indicate what is the status of Cow in mirage.

<table>
<tr>
  <th>Language</th>
  <th>Quotations</th>
  <th>Code generation</th>
  <th>Runtime API</th>
</tr><tr>
  <td>HTML</td>
  <td class="impl_green"></td>
  <td class="impl_green"></td>
  <td class="impl_green"></td>
</tr><tr>
  <td>CSS</td>
  <td class="impl_green"></td>
  <td class="impl_red">CSS validator</td>
  <td class="impl_green"></td>
</tr><tr>
  <td>Markdown</td>
  <td class="impl_red"></td>
  <td></td>
  <td class="impl_green"></td>
</tr><tr>
  <td>XML</td>
  <td class="impl_green"></td>
  <td class="impl_green"></td>
  <td class="impl_green"></td>
</tr><tr>
  <td>JSON</td>
  <td class="impl_red">Starting from <a href="https://github.com/jaked/cufp-metaprogramming-tutorial/tree/master/solutions/ocaml/json_quot">CUFP tutorial</a></td>
  <td class="impl_green"></td>
  <td class="impl_green"></td>
</tr><tr>
  <td>JavaScript</td>
  <td class="impl_red">Integration of <a href="https://www.github.com/jaked/ocamljs/">ocamljs/JSlib</a> and <a href="https://www.github.com/samoht/camlscript">camlscript</a> </td>
  <td></td>
  <td class="impl_red">Integration of <a href="https://www.github.com/jaked/ocamljs/">ocamljs client APIs</a></td>
</tr><tr>
  <td>SQL</td>
  <td class="impl_red">Integration of <a href="http://ocsigen.org/macaque/">macaque</a></td>
  <td class="impl_red">Integration of <a href="https://www.github.com/mirage/orm">ORM</a></td>
  <td></td>
</tr><tr>
  <td>Atom</td>
  <td></td>
  <td></td>
  <td class="impl_orange">Minimal set to run mirage blog</td>
</tr><tr>
  <td>Twitter</td>
  <td></td>
  <td></td>
  <td class="impl_orange">no OAuth integration yet</td>
</tr>
</table>

The legend for this table is :

<table class="impl">
<tr>
  <td class="impl_green">Integrated in Cow</td>
  <td class="impl_orange">Prototyped in Cow</td>
  <td class="impl_red">On the roadmap</td>
  <td>Nothing planned</td>
</tr>
</table>