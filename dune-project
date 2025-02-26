(lang dune 3.11)

(name dlx)

(generate_opam_files true)

(source
 (github kodyvajjha/ocaml-dlx))

(authors "Koundinya Vajjha")

(maintainers "Maintainer Name")

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (name dlx)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends ocaml dune containers printbox printbox-text ppx_deriving)
 (tags
  (topics "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
