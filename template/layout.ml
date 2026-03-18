open Tw_html

type tab = Home | Blog | Docs | Api | Community

(* Helper: parse a Tw class string *)
let tw s = match Tw.of_string s with Ok t -> t | Error (`Msg e) -> failwith e

(* SVG icons as raw HTML strings *)
let github_svg =
  raw
    {|<svg width="26" height="26" viewBox="0 0 26 26" fill="none" xmlns="http://www.w3.org/2000/svg"><g clip-path="url(#clip0_317_1697)"><path fill-rule="evenodd" clip-rule="evenodd" d="M12.8119 0.642883C5.80696 0.642883 0.133301 6.31654 0.133301 13.3214C0.133301 18.9317 3.76254 23.6703 8.80227 25.3502C9.4362 25.4612 9.67392 25.0808 9.67392 24.748C9.67392 24.4469 9.65807 23.4485 9.65807 22.3866C6.47258 22.973 5.64848 21.6101 5.39491 20.8969C5.25227 20.5324 4.63419 19.4072 4.09535 19.106C3.6516 18.8683 3.01767 18.2819 4.0795 18.2661C5.07794 18.2502 5.79111 19.1853 6.02883 19.5656C7.1699 21.4833 8.99245 20.9444 9.72147 20.6116C9.8324 19.7875 10.1652 19.2328 10.5297 18.9159C7.70874 18.5989 4.76098 17.5054 4.76098 12.6558C4.76098 11.277 5.25227 10.136 6.06053 9.24846C5.93375 8.9315 5.48999 7.63194 6.18732 5.88864C6.18732 5.88864 7.24915 5.55583 9.67392 7.18819C10.6882 6.90292 11.7659 6.76029 12.8436 6.76029C13.9212 6.76029 14.9989 6.90292 16.0132 7.18819C18.438 5.53998 19.4998 5.88864 19.4998 5.88864C20.1971 7.63194 19.7534 8.9315 19.6266 9.24846C20.4349 10.136 20.9261 11.2612 20.9261 12.6558C20.9261 17.5212 17.9625 18.5989 15.1416 18.9159C15.6012 19.3121 15.9974 20.0728 15.9974 21.2614C15.9974 22.9572 15.9815 24.3201 15.9815 24.748C15.9815 25.0808 16.2192 25.477 16.8532 25.3502C19.37 24.5005 21.5571 22.8829 23.1065 20.7251C24.6559 18.5673 25.4897 15.9779 25.4904 13.3214C25.4904 6.31654 19.8168 0.642883 12.8119 0.642883Z" class="fill-current" /></g><defs><clipPath id="clip0_317_1697"><rect width="25.3571" height="25.3571" class="fill-current" transform="translate(0.133301 0.642883)" /></clipPath></defs></svg>|}

let book_svg =
  raw
    {|<svg width="26" height="26" viewBox="0 0 26 26" fill="none" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" clip-rule="evenodd" d="M12.8832 26C19.8853 26 25.5617 20.3236 25.5617 13.3214C25.5617 6.31927 19.8853 0.642883 12.8832 0.642883C5.88098 0.642883 0.20459 6.31927 0.20459 13.3214C0.20459 20.3236 5.88098 26 12.8832 26ZM6.01602 6.98218C8.24831 6.99208 9.91567 7.27108 11.1086 7.84062C11.4934 8.02073 11.8521 8.25196 12.175 8.52804C12.2317 8.57733 12.2771 8.63821 12.3082 8.70656C12.3393 8.77491 12.3554 8.84915 12.3553 8.92424V20.0546C12.3554 20.0812 12.3477 20.1073 12.3332 20.1295C12.3186 20.1518 12.2979 20.1693 12.2734 20.1798C12.249 20.1904 12.2221 20.1935 12.1959 20.1889C12.1697 20.1842 12.1455 20.172 12.1262 20.1537C10.7163 18.8211 8.36255 18.6019 6.01602 18.6019C5.41379 18.6019 4.95947 18.1202 4.95947 17.4816V8.03542C4.95916 7.8623 5.00139 7.69175 5.08245 7.53878C5.16352 7.38581 5.28092 7.25511 5.42436 7.15816C5.5991 7.04071 5.80549 6.97932 6.01602 6.98218ZM19.7511 6.98218C19.9616 6.97896 20.168 7.04001 20.3428 7.15717C20.4867 7.25409 20.6044 7.38494 20.6858 7.53817C20.7671 7.6914 20.8094 7.86229 20.809 8.03575V17.5447C20.809 17.8249 20.6977 18.0936 20.4995 18.2918C20.3014 18.4899 20.0327 18.6012 19.7525 18.6012C15.9674 18.6009 14.48 19.3048 13.6324 20.1468C13.6141 20.1646 13.591 20.1767 13.5659 20.1815C13.5408 20.1863 13.5149 20.1836 13.4913 20.1737C13.4677 20.1638 13.4476 20.1471 13.4335 20.1258C13.4194 20.1045 13.4118 20.0795 13.4119 20.054V8.92292C13.4118 8.84787 13.4279 8.77367 13.4589 8.70534C13.49 8.637 13.5353 8.57609 13.5918 8.52672C13.915 8.25118 14.2738 8.02041 14.6586 7.84062C15.8515 7.26976 17.5188 6.99208 19.7511 6.98218Z" class="fill-current" /></svg>|}

let rss_svg =
  raw
    {|<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" width="26" height="26"><path stroke-linecap="round" stroke-linejoin="round" d="M12.75 19.5v-.75a7.5 7.5 0 0 0-7.5-7.5H4.5m0-6.75h.75c7.87 0 14.25 6.38 14.25 14.25v.75M6 18.75a.75.75 0 1 1-1.5 0 .75.75 0 0 1 1.5 0Z" /></svg>|}

(* Navigation link *)
let nav_link ~tab ~current_tab ~href label =
  let base_tw = [ Tw.hover [ Tw.text_white ] ] in
  let active_tw =
    if tab = current_tab then [ Theme.text_blue; Tw.font_bold ] else []
  in
  a ~at:[ At.href href ] ~tw:(base_tw @ active_tw) [ txt label ]

(* Social icon link *)
let icon_link ~href ~title:t icon =
  a
    ~at:[ At.href href; At.title t ]
    ~tw:[ tw "opacity-60"; Tw.hover [ tw "opacity-100" ]; Tw.transition_opacity ]
    [ icon ]

(* The sidebar *)
let sidebar ~tab =
  div
    ~tw:
      [
        Theme.font_space;
        Tw.flex;
        Tw.flex_col;
        Tw.items_center;
        Tw.justify_center;
        Tw.md [ Tw.justify_start; Tw.items_start; tw "w-[152px]"; tw "shrink-0"; tw "grow-0" ];
        Tw.mb 7;
      ]
    [
      (* Logo *)
      a
        ~at:[ At.href "/" ]
        ~tw:
          [
            Tw.w_full;
            Tw.flex;
            Tw.items_center;
            Tw.justify_center;
            Tw.pt 3;
            Tw.pb 4;
            Tw.rounded_md;
            tw "bg-white/0";
            Tw.md [ tw "bg-white/10" ];
          ]
        [ img ~at:[ At.src "/logo.svg"; At.alt "Mirage OS Logo" ] () ];
      (* Nav + social icons *)
      div
        ~tw:
          [
            Tw.p 2;
            Tw.flex;
            Tw.flex_col_reverse;
            Tw.items_center;
            Tw.md [ Tw.items_start ];
          ]
        [
          (* Social icons *)
          div
            ~tw:
              [
                Tw.flex;
                Tw.flex_wrap;
                Tw.gap 2;
                Tw.text_white;
                Tw.mt 4;
              ]
            [
              icon_link
                ~href:"https://github.com/mirage"
                ~title:"Mirage GitHub Organisation"
                github_svg;
              icon_link
                ~href:
                  "https://ocaml.org/packages/search?q=tag%3A%22org%3Amirage%22"
                ~title:"Mirage Packages Documentation"
                book_svg;
              icon_link ~href:"/feed.xml" ~title:"MirageOS RSS Feed" rss_svg;
            ];
          (* Nav links *)
          div
            ~tw:
              [
                Tw.flex;
                Tw.md [ Tw.flex_col ];
                Tw.space_x 3;
                Tw.md [ Tw.space_y 3; Tw.space_x 0 ];
                Tw.md [ Tw.mb 0 ];
                Theme.text_grey;
                Tw.flex_wrap;
                Tw.justify_center;
              ]
            [
              nav_link ~tab ~current_tab:Home ~href:"/" "Home";
              nav_link ~tab ~current_tab:Blog ~href:"/blog" "Blog";
              nav_link ~tab ~current_tab:Docs ~href:"/docs" "Docs";
              nav_link ~tab ~current_tab:Api
                ~href:
                  "https://ocaml.org/packages/search?q=tag%3A%22org%3Amirage%22"
                "API";
              nav_link ~tab ~current_tab:Community ~href:"/community"
                "Community";
            ];
        ];
    ]

let head_content ~description =
  [
    meta
      ~at:
        [
          At.name "viewport";
          At.content "width=device-width, initial-scale=1, shrink-to-fit=no";
        ]
      ();
    meta ~at:[ At.name "description"; At.content description ] ();
    link
      ~at:[ At.rel "icon"; At.type' "image/png"; At.href "/favicon.ico" ]
      ();
    link ~at:[ At.rel "stylesheet"; At.href "/main.css" ] ();
    link ~at:[ At.rel "stylesheet"; At.href "/syntax.css" ] ();
    link
      ~at:[ At.rel "stylesheet"; At.href "/vendor/font-files/inter.css" ]
      ();
    link
      ~at:
        [
          At.rel "stylesheet";
          At.href "/vendor/font-files/spacegrotesk.css";
        ]
      ();
    link
      ~at:
        [
          At.rel "alternate";
          At.type' "application/atom+xml";
          At.title "RSS Feed for mirageos.org";
          At.href "/feed.xml";
        ]
      ();
  ]

(* Custom styles for raw HTML content (headings, prose pre blocks) *)
let custom_style =
  raw
    {|<style>
h1, h2, h3, h4, h5, h6 { font-family: "Space Grotesk", sans-serif; }
.prose pre { background-color: #181818; }
</style>|}

(* Returns the full page as a Tw_html.t tree *)
let render_html ~description ~title:page_title ~tab inner =
  root
    ~at:[ At.lang "en" ]
    ~tw:[ tw "bg-repeat-y"; tw "bg-top" ]
    [
      head
        ([ title [ txt page_title ]; meta ~at:[ At.charset "utf-8" ] () ]
        @ head_content ~description
        @ [ custom_style ]);
      body
        ~at:
          [
            At.style
              "background-size: 100%; background-image: url(/img/wavesbg.png)";
          ]
        ~tw:
          [
            Tw.antialiased;
            tw "bg-no-repeat";
            tw "bg-top";
            Tw.min_h_screen;
            Theme.font_inter;
            Theme.text_body;
          ]
        [
          section
            ~tw:
              [
                Theme.bg_primary;
                Tw.p 4;
                Tw.flex;
                Tw.flex_col;
                Tw.md [ Tw.flex_row ];
                tw "rounded-[10px]";
                tw "max-w-[1080px]";
                Tw.m 3;
                tw "xl:mx-auto";
                tw "xl:my-[92px]";
                tw "2xl:max-w-[1738px]";
              ]
            [
              sidebar ~tab;
              div
                ~tw:
                  [
                    Tw.flex_1;
                    Tw.bg_white;
                    Tw.ml 4;
                    tw "rounded-[10px]";
                    Tw.min_w 0;
                  ]
                [ inner ];
            ];
        ];
    ]

(* Returns the full page as a string *)
let render ~description ~title ~tab inner =
  render_html ~description ~title ~tab inner
  |> Tw_html.to_string ~doctype:true
