open Printf
open Markdown

let quote str = "\"" ^ str ^ "\""

let escape ibuf =
  let obuf = Buffer.create (String.length ibuf) in
  let add c = Buffer.add_string obuf c in 
  for i = 0 to String.length ibuf - 1 do
    match ibuf.[i] with
    |'<' -> add "&lt;"
    |'>' -> add "&gt;"
    |'&' -> add "&amp;"
    |'#' -> add "&#35;"
    |c -> Buffer.add_char obuf c
  done;
  Buffer.contents obuf

let rec text = function
  | Text t    -> <:html< $str:t$ >>
  | Emph t    -> <:html< <i>$str:t$</i> >>
  | Bold t    -> <:html< <b>$str:t$</b> >>
  | Struck pt -> <:html< <del>$par_text pt$</del> >>
  | Code t    -> <:html< <code>$str:t$</code> >>
  | Link href -> <:html< <a href=$str:quote href.href_target$>$str:href.href_desc$</a> >>
  | Anchor a  -> <:html< <a name=$str:quote a$/> >>
  | Image img -> <:html< <img src=$str:quote img.img_src$ alt=$str:quote img.img_alt$/> >>

and para = function
    Normal pt        -> <:html< $par_text pt$ >>
  | Pre (t,kind)     -> <:html< <pre><code>$str:escape t$</code></pre> >>
  | Heading (1,pt)   -> <:html< <h1>$par_text pt$</h1> >>
  | Heading (2,pt)   -> <:html< <h2>$par_text pt$</h2> >>
  | Heading (3,pt)   -> <:html< <h3>$par_text pt$</h3> >>
  | Heading (_,pt)   -> <:html< <h4>$par_text pt$</h4> >>
  | Quote pl         -> <:html< <blockquote>$paras pl$</blockquote> >>
  | Ulist (pl,pll)   -> let l = pl :: pll in <:html< <ul>$li l$ </ul> >>
  | Olist (pl,pll)   -> let l = pl :: pll in <:html< <ol>$li l$ </ol> >>

and par_text pt = <:html< $list:List.map text pt$ >>

and li pl =
  let aux p = <:html< <li>$paras p$</li> >> in
  <:html< $list:List.map aux pl$ >>

and paras ps =
  let aux p = <:html< <p>$para p$</p> >> in
  <:html< $list:List.map aux  ps$ >>

let t ps =
  <:html< <div class="post"> $paras ps$ </div> >>
