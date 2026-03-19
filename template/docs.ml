open Tw_html

let title = "MirageOS Documentation"

let description =
  "Learn how to build your own operating system from the MirageOS \
   documentation."

let tab = Layout.Docs
let doc_link = Theme.doc_link
let plain_link ~href label = Theme.link_blue ~href [ txt label ]
let section_title = Theme.section_title

let render ~(weeklies : Mirageio_data.Weekly.t list) =
  div
    [
      (* Header *)
      div
        ~tw:[ Tw.text_left; Tw.px 8; Tw.py 7 ]
        [
          div
            ~tw:[ Tw.flex; Tw.items_baseline ]
            [
              h1 ~tw:[ Tw.text_3xl; Tw.font_bold ] [ txt "Documentation" ];
              p
                ~tw:[ Tw.font_bold; Theme.text_grey; Tw.ml 2 ]
                [ txt "and guides" ];
            ];
          div
            ~tw:[ Theme.text_grey; Tw.mt 2; Tw.text_sm ]
            [
              txt
                "Welcome to the MirageOS wiki! Read along to learn how to \
                 build unikernels.";
            ];
        ];
      Theme.separator ();
      (* Main content *)
      div
        ~tw:[ Tw.flex; Tw.flex_col; Tw.lg [ Tw.flex_row ] ]
        [
          div ~tw:[ Tw.flex_1 ]
            [
              div
                ~tw:[ Tw.grid; Tw.grid_cols 1; Tw.lg [ Tw.grid_cols 2 ] ]
                [
                  (* Background *)
                  div
                    ~tw:[ Tw.px 8; Tw.py 6; Tw.border_b; Tw.border_black ]
                    [
                      section_title "Background";
                      div
                        ~tw:[ Tw.space_y 2; Tw.flex; Tw.flex_col ]
                        [
                          doc_link ~href:"/docs/overview-of-mirage"
                            ~icon:"\xe2\x99\xa6" "Overview of MirageOS";
                          doc_link ~href:"/docs/security"
                            ~icon:"\xf0\x9f\x9b\xa1"
                            "Security disclosure process";
                          doc_link ~href:"/docs/technical-background"
                            ~icon:"\xe2\x9a\x99" "Technical Background";
                          doc_link ~href:"/docs/faq" ~icon:"\xe2\x9d\x93"
                            "Frequently Asked Questions";
                          doc_link ~href:"/papers" ~icon:"\xf0\x9f\x93\x9d"
                            "Papers and Articles";
                          doc_link ~href:"/docs/talks" ~icon:"\xf0\x9f\x8e\x9e"
                            "Videos and Slides";
                          doc_link ~href:"/docs/gallery"
                            ~icon:"\xf0\x9f\x93\xa2"
                            "Unikernels used in production";
                        ];
                    ];
                  (* Getting Started *)
                  div
                    ~tw:
                      [
                        Tw.px 8;
                        Tw.py 6;
                        Tw.border_b;
                        Tw.border_black;
                        Tw.lg [ Tw.border_l ];
                      ]
                    [
                      section_title "Getting Started";
                      div
                        ~tw:[ Tw.space_y 2; Tw.flex; Tw.flex_col ]
                        [
                          doc_link ~href:"/docs/install" ~icon:"\xe2\x9c\xa8"
                            "Installation";
                          doc_link ~href:"/docs/hello-world"
                            ~icon:"\xf0\x9f\x91\x8b" "Hello Mirage World";
                          doc_link ~href:"/docs/learning"
                            ~icon:"\xf0\x9f\x93\x96" "Learning about Mirage";
                          doc_link ~href:"/docs/mirage-www"
                            ~icon:"\xf0\x9f\x9b\xa0" "Building the website";
                          doc_link ~href:"/docs/deploying-via-ci"
                            ~icon:"\xf0\x9f\x8f\x97"
                            "Deploying via Continuous Integration";
                          doc_link ~href:"/docs/opam" ~icon:"\xf0\x9f\x93\x94"
                            "Keeping up-to-date";
                          doc_link ~href:"/docs/breaking-changes"
                            ~icon:"\xf0\x9f\x94\xa8" "Breaking changes";
                          doc_link ~href:"/docs/mirage-3.0-errors"
                            ~icon:"\xf0\x9f\x86\x98" "Error Handling";
                          doc_link ~href:"/docs/contributing"
                            ~icon:"\xe2\x98\x9d" "Contributing to MirageOS";
                          doc_link ~href:"/docs/arm64" ~icon:"\xf0\x9f\x92\xbe"
                            "Mirage on ARM64 (e.g. Raspberry Pi 3)";
                        ];
                    ];
                  (* Xen Backend *)
                  div
                    ~tw:[ Tw.px 8; Tw.py 6; Tw.border_b; Tw.border_black ]
                    [
                      section_title "Xen Backend";
                      div
                        ~tw:[ Tw.space_y 2; Tw.flex; Tw.flex_col ]
                        [
                          plain_link ~href:"/docs/xen-events"
                            "How the Xen VM event system works";
                          plain_link ~href:"/docs/xen-synthesize-virtual-disk"
                            "Synthesizing virtual disks for Xen";
                          plain_link ~href:"/docs/xen-suspend"
                            "How Suspend and Resume work";
                          plain_link ~href:"/docs/xen-on-cubieboard2"
                            "Installing Xen on the Cubieboard2";
                          plain_link ~href:"/docs/libvirt-on-cubieboard"
                            "LibVirt on Cubieboard2";
                        ];
                    ];
                  (* Libraries *)
                  div
                    ~tw:
                      [
                        Tw.px 8;
                        Tw.py 6;
                        Tw.border_b;
                        Tw.border_black;
                        Tw.lg [ Tw.border_l ];
                      ]
                    [
                      section_title "Libraries";
                      div
                        ~tw:[ Tw.space_y 2; Tw.flex; Tw.flex_col ]
                        [
                          plain_link ~href:"/docs/tutorial-lwt"
                            "Threads: introduction to Lwt";
                          plain_link ~href:"/docs/performance"
                            "DNS Performance Tests";
                        ];
                    ];
                  (* Weekly calls *)
                  div
                    ~tw:
                      [ Tw.px 8; Tw.py 6; Tw.lg [ Tw.border_l; Tw.col_span 2 ] ]
                    [
                      div
                        ~tw:[ Tw.mb 4 ]
                        [
                          div
                            ~tw:[ Tw.text_lg; Theme.font_space; Tw.font_bold ]
                            [ txt "Former weekly calls and release notes" ];
                          p
                            ~tw:[ Theme.text_grey; Tw.text_xs ]
                            [
                              txt
                                "Calls taken place every two weeks and \
                                 announced on the mailing list.";
                            ];
                        ];
                      div
                        ~tw:[ Tw.space_y 2; Tw.flex; Tw.flex_col ]
                        [
                          div
                            ~tw:[ Tw.text_sm; Tw.italic; Tw.space_y 3 ]
                            (List.map
                               (fun (item : Mirageio_data.Weekly.t) ->
                                 div
                                   [
                                     Theme.link_blue
                                       ~href:("/weekly/" ^ item.permalink)
                                       [ txt item.subject ];
                                     p
                                       [
                                         span ~tw:[ Theme.text_grey ]
                                           [ txt "on" ];
                                         txt (" " ^ item.description);
                                       ];
                                   ])
                               weeklies);
                        ];
                    ];
                ];
            ];
        ];
    ]
