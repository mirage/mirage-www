open Tw_html

let title = "MirageOS Community"

let description =
  "Get in touch with the a community of hackers, developers, and enthusiasts \
   who use MirageOS to build stable and safe systems."

let tab = Layout.Community

(* link-blue helper for inline raw HTML content *)
let lb ~href children = Theme.link_blue ~href children

let render () =
  div
    [
      (* Top 2-column: Community + Research *)
      div
        ~tw:[ Tw.grid; Tw.grid_cols 1; Tw.lg [ Tw.grid_cols 2 ] ]
        [
          (* The Community *)
          div
            ~tw:[ Tw.p 8; Tw.space_y 6; Tw.flex_1; Tw.text_center ]
            [
              div
                ~tw:[ Tw.pt 6 ]
                [
                  img ~tw:[ Tw.inline_block ]
                    ~at:
                      [
                        At.src "/img/community/community.svg";
                        At.v "height" "150px";
                        At.alt "Community Image";
                      ]
                    ();
                ];
              h2 ~tw:[ Tw.text_3xl; Tw.font_bold ] [ txt "The Community" ];
              div
                ~tw:
                  [
                    Tw.text_left; Tw.text_sm; Theme.text_dark_grey; Tw.space_y 6;
                  ]
                [
                  p
                    [
                      txt "All MirageOS development is done via ";
                      lb ~href:"https://github.com" [ txt "GitHub" ];
                      txt ", consisting of a set of ";
                      lb ~href:"https://github.com/mirage" [ txt "libraries" ];
                      txt
                        " that form the core distribution. It is all glued \
                         together via the ";
                      lb ~href:"https://opam.ocaml.org" [ txt "OPAM" ];
                      txt
                        " package manager. All of the libraries are either \
                         under the ";
                      lb ~href:"http://www.gnu.org/licenses/lgpl-2.1.html"
                        [ txt "LGPLv2" ];
                      txt " or the liberal ";
                      lb ~href:"http://en.wikipedia.org/wiki/ISC_license"
                        [ txt "ISC" ];
                      txt
                        " license. If you find bugs or installation issues, \
                         please report them via the main ";
                      lb ~href:"https://github.com/mirage/mirage/issues"
                        [ txt "issue tracker" ];
                      txt
                        ". Broader queries or OCaml questions are very welcome \
                         on our ";
                      lb
                        ~href:
                          "http://lists.xenproject.org/cgi-bin/mailman/listinfo/mirageos-devel"
                        [ txt "mailing list" ];
                      txt ".";
                    ];
                ];
            ];
          (* The Research Project *)
          div
            ~tw:
              [
                Tw.p 8;
                Tw.flex_1;
                Tw.space_y 6;
                Tw.text_center;
                Tw.border_t;
                Tw.border_black;
                Tw.lg [ Theme.tw "border-t-0"; Tw.border_l ];
              ]
            [
              div
                ~tw:[ Tw.pt 6 ]
                [
                  img ~tw:[ Tw.inline_block ]
                    ~at:
                      [
                        At.src "/img/community/research.svg";
                        At.v "height" "150px";
                        At.alt "Community Image";
                      ]
                    ();
                ];
              h2
                ~tw:[ Tw.text_3xl; Tw.font_bold ]
                [ txt "The Research Project" ];
              div
                ~tw:
                  [
                    Tw.text_left; Tw.text_sm; Theme.text_dark_grey; Tw.space_y 6;
                  ]
                [
                  p
                    [
                      txt "MirageOS started with funding in 2009 from the ";
                      lb ~href:"http://www.rcuk.ac.uk/" [ txt "RCUK" ];
                      txt " ";
                      lb ~href:"http://horizon.ac.uk"
                        [ txt "Horizon Digital Economy" ];
                      txt " Research Hub grant, ";
                      lb
                        ~href:
                          "http://gow.epsrc.ac.uk/NGBOViewGrant.aspx?GrantRef=EP/G065802/1"
                        [ txt "EP/G065802/1" ];
                      txt ". Amazon also granted us an ";
                      lb ~href:"http://aws.amazon.com/education/"
                        [ txt "Amazon in Education" ];
                      txt " award and Verisign ";
                      lb
                        ~href:
                          "http://www.cl.cam.ac.uk/news/2011/03/anil-madhavapeddy-wins-verisign-grant/"
                        [ txt "sponsored" ];
                      txt " work via an ";
                      lb ~href:"http://www.youtube.com/watch?v=5-4lbyD_Fvw"
                        [ txt "Internet Infrastructure Award" ];
                      txt ", and ";
                      lb ~href:"http://www.rackspace.com/cloud/"
                        [ txt "Rackspace" ];
                      txt
                        " gives us developer resources on their cloud. Work \
                         has also been supported by the ";
                      lb
                        ~href:"http://www.cl.cam.ac.uk/research/srg/netos/mrc2/"
                        [ txt "MRC2" ];
                      txt " and ";
                      lb ~href:"http://ocaml.io" [ txt "OCaml Labs" ];
                      txt " projects.";
                    ];
                  p
                    [
                      txt
                        "The research leading to this code has also received \
                         funding from the European Union's Seventh Framework \
                         Programme FP7/2007-2013 under the ";
                      lb ~href:"http://www.trilogy2.eu/" [ txt "Trilogy 2" ];
                      txt " project (grant agreement no 317756) and the ";
                      lb ~href:"http://usercentricnetworking.eu/"
                        [ txt "User Centric Networking" ];
                      txt
                        " project (grant agreement no 611001). Publications \
                         are ";
                      lb ~href:"/docs/papers" [ txt "open access" ];
                      txt ".";
                    ];
                ];
            ];
        ];
      (* 3-column: Discussion / Mailing list / IRC *)
      div
        ~tw:
          [
            Tw.grid;
            Tw.grid_cols 1;
            Tw.lg [ Tw.grid_cols 3 ];
            Tw.text_sm;
            Tw.border_t;
            Tw.border_black;
          ]
        [
          (* Discussion forum *)
          div
            ~tw:[ Theme.bg_cyan; Tw.py 5; Tw.px 6; Tw.space_y 3 ]
            [
              img
                ~at:
                  [
                    At.src "/img/community/users.svg";
                    At.alt "Community icon";
                    At.v "height" "40";
                  ]
                ();
              p
                [
                  txt "Browse through our ";
                  lb ~href:"https://discuss.ocaml.org/tags/mirageos"
                    [ txt "discussion forum" ];
                  txt
                    " and participate or start a new thread. We use the \
                     discourse instance kindly provided by OCaml.";
                ];
            ];
          (* Mailing list *)
          div
            ~tw:
              [
                Tw.py 5;
                Tw.px 6;
                Tw.space_y 3;
                Tw.border_t;
                Tw.border_black;
                Tw.lg [ Theme.tw "border-t-0"; Tw.border_l ];
              ]
            [
              img
                ~at:
                  [
                    At.src "/img/community/envelope.svg";
                    At.alt "Envelope icon";
                    At.v "height" "40";
                  ]
                ();
              p
                [
                  txt "Join the e-mail ";
                  lb
                    ~href:
                      "http://lists.xenproject.org/cgi-bin/mailman/listinfo/mirageos-devel"
                    [ txt "developer mailing list" ];
                  txt
                    " or search the past archives. This is a fairly low-volume \
                     list, and beginner questions are welcome.";
                ];
            ];
          (* IRC *)
          div
            ~at:[ At.style "background-color: rgba(255, 152, 0, 0.4)" ]
            ~tw:
              [
                Tw.py 5;
                Tw.px 6;
                Tw.space_y 3;
                Tw.border_t;
                Tw.border_black;
                Tw.lg [ Theme.tw "border-t-0"; Tw.border_l ];
              ]
            [
              img
                ~at:
                  [
                    At.src "/img/community/mirc.svg";
                    At.alt "MIRC icon";
                    At.v "height" "40";
                  ]
                ();
              p
                [
                  txt
                    "The MirageOS community can be found on IRC in the #mirage \
                     channel on ";
                  Theme.link_orange ~href:"https://libera.chat/"
                    [ txt "Libera.Chat" ];
                  txt
                    " . Bear in mind that questions are more likely to be \
                     answered via e-mail if we're idling on IRC.";
                ];
            ];
        ];
      (* Bottom 2-column: Core Team + Contributors *)
      div
        ~tw:
          [
            Tw.grid;
            Tw.grid_cols 1;
            Tw.lg [ Tw.grid_cols 2 ];
            Tw.border_t;
            Tw.border_black;
          ]
        [
          (* Core Team *)
          div
            ~tw:[ Tw.p 9; Tw.space_y 6; Tw.text_sm ]
            [
              div
                [
                  h3 ~tw:[ Tw.text_lg; Tw.font_bold ] [ txt "Core Team" ];
                  p ~tw:[ Theme.text_grey ]
                    [
                      txt
                        "One of us will review every patch that goes into the \
                         main distribution. Get in touch with any of us \
                         individually if you're interested in a \
                         MirageOS-related internship at our respective \
                         institutions.";
                    ];
                ];
              div
                [
                  div [ txt "Lexicographically ordered by last name:" ];
                  ul
                    ~tw:[ Tw.list_disc; Tw.ml 4; Tw.space_y 2; Tw.mt 2 ]
                    [
                      li
                        [
                          strong [ txt "Pierre Alain" ];
                          txt ", University of Rennes 1, ";
                          lb ~href:"https://github.com/palainp"
                            [ txt "@palainp" ];
                        ];
                      li
                        [
                          strong [ txt "Romain Calascibetta" ];
                          txt " ";
                          lb ~href:"https://github.com/dinosaure"
                            [ txt "@dinosaure" ];
                        ];
                      li
                        [
                          strong
                            [
                              lb ~href:"https://gazagnaire.org"
                                [ txt "Thomas Gazagnaire" ];
                            ];
                          txt ", ";
                          lb ~href:"https://tarides.com" [ txt "Tarides" ];
                          txt ", ";
                          lb ~href:"https://github.com/samoht" [ txt "@samoht" ];
                        ];
                      li
                        [
                          strong
                            [
                              lb ~href:"http://roscidus.com/blog/"
                                [ txt "Thomas Leonard" ];
                            ];
                          txt ", ";
                          lb ~href:"https://github.com/talex5" [ txt "@talex5" ];
                        ];
                      li
                        [
                          strong
                            [
                              lb ~href:"http://anil.recoil.org"
                                [ txt "Anil Madhavapeddy" ];
                            ];
                          txt ", University of Cambridge, ";
                          lb ~href:"https://github.com/avsm" [ txt "@avsm" ];
                        ];
                      li
                        [
                          strong
                            [
                              lb ~href:"https://hannes.robur.coop"
                                [ txt "Hannes Mehnert" ];
                            ];
                          txt ", ";
                          lb ~href:"http://robur.coop" [ txt "robur" ];
                          txt ", ";
                          lb ~href:"https://github.com/hannesm"
                            [ txt "@hannesm" ];
                        ];
                      li
                        [
                          strong
                            [
                              lb ~href:"https://www.lortex.org"
                                [ txt "Lucas Pluvinage" ];
                            ];
                          txt ", ";
                          lb ~href:"https://github.com/TheLortex"
                            [ txt "@TheLortex" ];
                        ];
                      li
                        [
                          strong
                            [
                              lb ~href:"http://www.somerandomidiot.com"
                                [ txt "Mindy Preston" ];
                            ];
                          txt " ";
                          lb ~href:"https://github.com/yomimono"
                            [ txt "@yomimono" ];
                        ];
                      li
                        [
                          strong
                            [
                              lb ~href:"http://dave.recoil.org"
                                [ txt "David Scott" ];
                            ];
                          txt ", Docker, ";
                          lb ~href:"https://github.com/djs55" [ txt "@djs55" ];
                        ];
                      li
                        [
                          strong
                            [
                              lb ~href:"http://www.skjegstad.com"
                                [ txt "Magnus Skjegstad" ];
                            ];
                          txt ", ";
                          lb ~href:"https://github.com/magnuss"
                            [ txt "@magnuss" ];
                        ];
                    ];
                ];
              div
                [
                  h3 ~tw:[ Tw.text_lg; Tw.font_bold ] [ txt "Emeriti" ];
                  ul
                    ~tw:[ Tw.list_disc; Tw.ml 4; Tw.space_y 2; Tw.mt 2 ]
                    [
                      li
                        [
                          strong
                            [
                              lb ~href:"http://amirchaudhry.com/"
                                [ txt "Amir Chaudhry" ];
                            ];
                          txt " ";
                          lb ~href:"https://github.com/amirmc" [ txt "@amirmc" ];
                        ];
                      li
                        [
                          strong
                            [
                              lb ~href:"https://lucina.net/"
                                [ txt "Martin Lucina" ];
                            ];
                          txt ", ";
                          lb ~href:"https://github.com/mato" [ txt "@mato" ];
                        ];
                      li
                        [
                          strong
                            [
                              lb ~href:"http://mort.io/"
                                [ txt "Richard Mortier" ];
                            ];
                          txt ", University of Cambridge & Kvasir Analytics ";
                          lb ~href:"https://github.com/mor1" [ txt "@mor1" ];
                        ];
                    ];
                ];
            ];
          (* Contributors *)
          div
            ~tw:
              [
                Tw.p 9;
                Tw.space_y 6;
                Tw.text_sm;
                Tw.border_t;
                Tw.border_black;
                Tw.lg [ Theme.tw "border-t-0"; Tw.border_l ];
              ]
            [
              div
                [
                  h3 ~tw:[ Tw.text_lg; Tw.font_bold ] [ txt "Contributors" ];
                  p ~tw:[ Theme.text_grey ]
                    [
                      txt
                        "One of us will review every patch that goes into the \
                         main distribution. Get in touch with any of us \
                         individually if you're interested in a \
                         MirageOS-related internship at our respective \
                         institutions.";
                    ];
                ];
              div
                [
                  ul
                    ~tw:[ Tw.list_disc; Tw.ml 4; Tw.space_y 2; Tw.mb 4 ]
                    [
                      li
                        [
                          lb ~href:"https://github.com/vbmithr"
                            [ em [ txt "Vincent Bernardoff" ] ];
                        ];
                      li
                        [
                          lb ~href:"https://github.com/Weichen81"
                            [ em [ txt "Wei Chen" ] ];
                          txt ", ARM";
                        ];
                      li
                        [
                          lb ~href:"http://www.cl.cam.ac.uk/~jac22/"
                            [ em [ txt "Jon Crowcroft" ] ];
                          txt ", University of Cambridge";
                        ];
                      li
                        [
                          lb ~href:"https://github.com/haesbaert"
                            [ em [ txt "Christiano Haesbaert" ] ];
                          txt ", genua mbh";
                        ];
                      li
                        [
                          lb ~href:"http://www.cl.cam.ac.uk/~smh22/"
                            [ em [ txt "Steven Hand" ] ];
                          txt ", Google";
                        ];
                      li
                        [
                          lb ~href:"https://github.com/pqwy"
                            [ em [ txt "David Kaloper" ] ];
                          txt ", University of Cambridge";
                        ];
                      li
                        [
                          lb ~href:"https://github.com/ricarkol"
                            [ em [ txt "Ricardo Koller" ] ];
                          txt ", IBM Research";
                        ];
                      li
                        [
                          lb ~href:"http://jon.recoil.org/"
                            [ em [ txt "Jon Ludlam" ] ];
                          txt ", Citrix Systems R&D";
                        ];
                      li
                        [
                          lb ~href:"http://www.cl.cam.ac.uk/~rp452/"
                            [ em [ txt "Raphael Proust" ] ];
                          txt ", University of Cambridge";
                        ];
                      li
                        [
                          lb ~href:"http://www.cl.cam.ac.uk/~cr409/"
                            [ em [ txt "Haris Rotsos" ] ];
                          txt ", University of Cambridge";
                        ];
                      li
                        [
                          lb ~href:"https://github.com/kensan"
                            [ em [ txt "Adrian-Ken Rueegsegger" ] ];
                        ];
                      li
                        [
                          lb ~href:"https://github.com/dsheets"
                            [ em [ txt "David Sheets" ] ];
                        ];
                      li
                        [
                          lb ~href:"https://github.com/balrajsingh"
                            [ em [ txt "Balraj Singh" ] ];
                        ];
                      li
                        [
                          lb ~href:"https://github.com/djwillia"
                            [ em [ txt "Dan Williams" ] ];
                          txt ", IBM Research";
                        ];
                      li
                        [
                          lb ~href:"https://www.cl.cam.ac.uk/~jdy22/"
                            [ em [ txt "Jeremy Yallop" ] ];
                          txt ", University of Cambridge";
                        ];
                    ];
                  p
                    [
                      txt
                        "The MirageOS3 release announcement contained a more \
                         complete list. For a complete list, please look at \
                         the contributors to individual git repositories. If \
                         you are missing here, please add yourself via a PR to \
                         the mirage-www repository.";
                    ];
                ];
            ];
        ];
    ]
