(lang dune 3.8)
(using mdx 0.4)
(using directory-targets 0.1)

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
  (ocaml
   (>= 4.14))
  dune
  dream
  dream-mirage
  (tcpip (>= 8.0))
  (mirage-time (>= 3.0))
  (mirage-kv-mem (>= 3.2.1))
  (mirage-clock-unix (>= 3.0))
  (mirage-unix (>= 5.0.0))
  (ptime (>= 0.8.1))
  (crunch (and :build (>= 3.1.0)))
  (cmarkit (and :build
   (>= 0.2.0)))
  (hilite (and :build
   (>= 0.4.0)))
  (tailwindcss :build)
  (yaml :build)
  (fmt :build)
  (ppx_deriving_yaml (and :build (>= 0.2.1)))
  (mdx :with-test)
  (mirage :with-test)
  (mirage-block-unix :with-test)
  (mirage-kv-unix (and :with-test (>= 3.0.0)))
  (mirage-net-unix :with-test)
  (mirage-logs :with-test)
  (mirage-crypto-rng-mirage :with-test)
  (mirage-bootvar :with-test)
  (dns-certify :with-test)
  (lwt :with-test)
  (charrua-client :with-test)))
