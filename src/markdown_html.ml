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
    |c -> Buffer.add_char obuf c
  done;
  Buffer.contents obuf

let rec text = function
    Text t    -> <:html< $str:escape t$ >>
  | Emph t    -> <:html< <i>$str:escape t$</> >>
  | Bold t    -> <:html< <b>$str:escape t$</> >>
  | Struck pt -> <:html< <del>$par_text pt$</> >>
  | Code t    -> <:html< <code>$str:escape t$ </> >>
  | Link href -> <:html< <a href=$str:quote href.href_target$>$str:escape href.href_desc$</> >>
  | Anchor a  -> <:html< <a name=$str:quote a$/> >>
  | Image img -> <:html< <img src=$str:quote img.img_src$ alt=$str:quote img.img_alt$/> >>

and para = function
    Normal pt        -> <:html< $par_text pt$ >>
  | Pre (t,kind)     -> <:html< <pre><code>$str:escape t$</></> >>
  | Heading (1,pt)   -> <:html< <h1>$par_text pt$</> >>
  | Heading (2,pt)   -> <:html< <h2>$par_text pt$</> >>
  | Heading (3,pt)   -> <:html< <h3>$par_text pt$</> >>
  | Heading (_,pt)   -> <:html< <h4>$par_text pt$</> >>
  | Quote pl         -> <:html< <blockquote>$paras pl$</> >>
  | Ulist (pl,pll)   -> let l = pl :: pll in <:html< <ul>$li l$ </> >>
  | Olist (pl,pll)   -> let l = pl :: pll in <:html< <ol>$li l$ </> >>

and par_text pt = <:html< $list:List.map text pt$ >>

and li pl =
  let aux p = <:html< <li>$paras p$</> >> in
  <:html< $list:List.map aux pl$ >>

and paras ps =
  let aux p = <:html< <p>$para p$</> >> in
  <:html< <div class="post"> $list:List.map aux  ps$ </> >>

let t = paras
