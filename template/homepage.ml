open Tw_html

let title = "Welcome to MirageOS"

let description =
  "MirageOS is a programming framework for building type-safe, modular systems."

let tab = Layout.Home

let render ~(blog_posts : Mirageio_data.Blog.t list) =
  div
    [
      (* Hero section *)
      div
        ~tw:
          [
            Tw.text_center;
            Theme.font_space;
            Theme.w_4_5;
            Tw.mx_auto;
            Tw.py 8;
            Tw.space_y 6;
          ]
        [
          h1
            ~tw:[ Tw.text_3xl; Tw.font_bold ]
            [
              txt
                "A programming framework for building type-safe, modular \
                 systems";
            ];
          div
            ~tw:
              [
                Tw.flex;
                Tw.flex_col;
                Tw.sm [ Tw.flex_row ];
                Tw.justify_center;
                Tw.items_center;
                Tw.sm [ Tw.space_x 6; Tw.space_y 0 ];
                Tw.space_y 4;
              ]
            [
              Theme.btn_primary ~href:"/docs/hello-world"
                [ span [ txt "Get Started" ] ];
              Theme.btn ~href:"https://github.com/mirage"
                [ Layout.github_svg; span [ txt "See on Github" ] ];
              Theme.btn ~href:"https://queue.acm.org/detail.cfm?id=2566628"
                [ Layout.book_svg; span [ txt "See Paper" ] ];
            ];
        ];
      hr ~tw:[ Tw.border_black ] ();
      (* Description + Features *)
      div
        ~tw:[ Tw.flex; Tw.flex_col; Tw.lg [ Tw.flex_row ] ]
        [
          div
            ~tw:[ Tw.p 9; Tw.space_y 4; Tw.flex_1 ]
            [
              p
                ~tw:[ Tw.font_medium; Theme.font_space; Tw.text_lg ]
                [
                  txt "MirageOS is a library operating system that constructs ";
                  Theme.link_blue
                    ~href:"https://en.wikipedia.org/wiki/Unikernel"
                    [ txt "unikernels" ];
                  txt
                    " for secure, high-performance network applications across \
                     a variety of cloud computing and mobile platforms.";
                ];
              p ~tw:[ Theme.font_inter ]
                [
                  txt
                    "Code can be developed on a normal OS such as Linux or \
                     macOS, and then compiled into a fully-standalone, \
                     specialised unikernel that runs under a Xen or KVM \
                     hypervisor.";
                ];
              p ~tw:[ Theme.font_inter ]
                [
                  txt
                    "This lets your services run more efficiently, securely \
                     and with finer control than with a full conventional \
                     software stack.";
                ];
              p ~tw:[ Theme.font_inter ]
                [
                  Theme.link_blue ~href:"/docs/mirage-4"
                    [ txt "Check what's new in MirageOS 4." ];
                ];
            ];
          div
            ~tw:
              [
                Tw.p 9;
                Tw.border_t;
                Tw.lg [ Theme.tw "border-t-0" ];
                Tw.lg [ Tw.border_l ];
                Tw.border_black;
                Theme.bg_cyan;
                Tw.flex_1;
                Tw.space_y 6;
              ]
            [
              Theme.feature_item ~icon:"/icon/fast-start.svg"
                ~alt:"Fast Start Icon" ~title:"Fast Start"
                "MirageOS applications take a few milliseconds to start-up \
                 instead of the few minutes that traditional OSes take.";
              Theme.feature_item ~icon:"/icon/binaries.svg" ~alt:"Binaries Icon"
                ~title:"Small Binaries"
                "MirageOS binaries are self-contained: they do not need an \
                 additional OS to execute. Even then, the size of MirageOS \
                 binary is usually a few megabytes.";
              Theme.feature_item ~icon:"/icon/footprint.svg"
                ~alt:"Footprint Icon" ~title:"Small Footprint"
                "MirageOS applications use a few megabytes of memory, while \
                 traditional applications and their associated OS waste \
                 gigabytes for simple applications.";
              Theme.feature_item ~icon:"/icon/safe-logic.svg"
                ~alt:"Safe Logic Icon" ~title:"Safe Logic"
                "MirageOS applications are written in OCaml, an industrial \
                 strength programming language supporting functional, \
                 imperative and object-oriented styles.";
            ];
        ];
      hr ~tw:[ Tw.border_black ] ();
      (* Info + Blog + Xen *)
      div
        ~tw:[ Tw.flex; Tw.flex_col; Tw.md [ Tw.flex_row ] ]
        [
          div
            ~tw:
              [
                Tw.p 9;
                Theme.bg_green;
                Tw.flex_1;
                Tw.space_y 6;
                Tw.w_full;
                Tw.md [ Theme.w_1_2 ];
                Tw.lg [ Theme.w_1_3 ];
              ]
            [
              p
                [
                  txt "MirageOS uses the ";
                  Theme.link_blue ~href:"https://ocaml.org/" [ txt "OCaml" ];
                  txt " language, with ";
                  Theme.link_blue ~href:"https://github.com/mirage"
                    [ txt "libraries" ];
                  txt
                    " that provide networking, storage and concurrency support \
                     that work under Unix during development, but become \
                     operating system drivers when being compiled for \
                     production deployment.";
                ];
              p
                [
                  txt
                    "The framework is fully event-driven, with no support for \
                     preemptive threading.";
                ];
              p
                [
                  Theme.link_blue ~href:"/blog/announcing-mirage-40"
                    [ txt "MirageOS 4.0" ];
                  txt " was released in March 2022, preceded by ";
                  Theme.link_blue ~href:"/blog/announcing-mirage-30-release"
                    [ txt "MirageOS 3.0" ];
                  txt " in February 2017, and ";
                  Theme.link_blue ~href:"/blog/announcing-mirage-20-release"
                    [ txt "MirageOS 2.0" ];
                  txt " in July 2014, and ";
                  Theme.link_blue ~href:"/blog/announcing-mirage10"
                    [ txt "MirageOS 1.0" ];
                  txt
                    " in December 2013. All the infrastructure you see here is ";
                  Theme.link_blue ~href:"https://github.com/mirage/mirage-www"
                    [ txt "self-hosted" ];
                  txt ".";
                ];
              p
                [
                  txt "Check out the ";
                  Theme.link_blue ~href:"/docs" [ txt "documentation" ];
                  txt ", compile your ";
                  Theme.link_blue ~href:"/docs/hello-world"
                    [ txt "hello world unikernel" ];
                  txt ", get started with the ";
                  Theme.link_blue ~href:"/docs/xen-boot" [ txt "public cloud" ];
                  txt ", or watch the ";
                  Theme.link_blue ~href:"/docs/talks" [ txt "talks" ];
                  txt ".";
                ];
            ];
          div
            ~tw:
              [
                Tw.w_full;
                Tw.md [ Theme.w_1_2 ];
                Tw.lg [ Theme.w_2_3 ];
                Tw.border_t;
                Tw.md [ Theme.tw "border-t-0" ];
                Tw.md [ Tw.border_l ];
                Tw.border_black;
                Tw.flex;
                Tw.flex_col;
                Tw.justify_between;
              ]
            [
              div
                ~tw:[ Tw.px 10; Tw.py 8 ]
                [
                  h2 ~tw:[ Tw.text_3xl; Tw.font_bold ] [ txt "Blog" ];
                  div
                    ~tw:[ Tw.space_y 2; Tw.mt 3 ]
                    (List.map
                       (fun (item : Mirageio_data.Blog.t) ->
                         div
                           ~tw:[ Tw.items_center; Tw.space_x 2 ]
                           [
                             img ~tw:[ Tw.inline ]
                               ~at:
                                 [
                                   At.src "/icon/speech-bubble.svg";
                                   At.alt "Speech Bubble Icon";
                                 ]
                               ();
                             Theme.link_blue
                               ~href:("/blog/" ^ item.permalink)
                               [ txt (" " ^ item.subject ^ " ") ];
                             span ~tw:[ Theme.text_grey ]
                               [
                                 txt
                                   ("(" ^ Util.date_to_string item.updated ^ ")");
                               ];
                           ])
                       blog_posts
                    @ [
                        div
                          [
                            Theme.link_blue ~href:"/blog"
                              [ txt "-> More on the blog" ];
                          ];
                      ]);
                ];
              div
                ~tw:
                  [
                    Tw.px 10;
                    Tw.py 8;
                    Theme.bg_orange;
                    Tw.flex;
                    Tw.flex_col;
                    Tw.lg [ Tw.flex_row ];
                    Tw.justify_center;
                    Tw.items_center;
                    Tw.border_t;
                    Tw.border_black;
                  ]
                [
                  img
                    ~tw:[ Tw.mb 7; Tw.lg [ Tw.mb 0; Tw.mr 8 ] ]
                    ~at:[ At.src "/img/xen.png"; At.alt "Xen Image" ]
                    ();
                  div
                    ~tw:[ Tw.font_medium; Tw.text_lg; Theme.font_space ]
                    [
                      txt
                        "MirageOS is a Xen and Linux Foundation incubator \
                         project.";
                    ];
                ];
            ];
        ];
    ]
