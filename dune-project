(lang dune 3.8)
(using mdx 0.4)

(name mirageio)

(documentation "https://mirage.github.io/mirage-www/")

(source
 (github mirage/mirage-www))

(license ISC)

(authors
  "Anil Madhavapeddy"
  "Amir Chaudhry"
  "Thomas Gazagnaire"
  "Richard Mortier"
  "Hannes Mehnert"
  "Mindy Preston"
  "Lucas Pluvinage"
  "Thomas Leonard"
  "Dave Scott"
  "Martin Keegan"
  "Thibaut Mattio")

(maintainers "mirageos-devel@list.xenproject.org")

(generate_opam_files true)

(package
 (name mirageio)
 (synopsis "Website infrastructure and content for mirageos.org")
 (description "Website infrastructure and content for mirageos.org")
 (depends
  (ocaml (>= 5.1))
  dune
  tw
  (ptime (>= 0.8.1))
  (cmarkit (and :build (>= 0.2.0)))
  (hilite (and :build (>= 0.5.0)))
  (yaml :build)
  (fmt :build)
  (ppx_deriving_yaml (and :build (>= 0.2.1)))
  (mdx :with-test)))
