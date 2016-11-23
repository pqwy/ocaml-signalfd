#!/usr/bin/env ocaml
#use "topfind"
#require "topkg"
#require "ocb-stubblr.topkg"
open Topkg

let opams = [Pkg.opam_file ~lint_deps_excluding:(Some ["ocb-stubblr"]) "opam"]
let build = Pkg.build ~cmd:Ocb_stubblr_topkg.cmd ()
let () =
  Pkg.describe "signalfd" ~build ~opams @@ fun c ->
    Ok [ Pkg.mllib ~api:["Signal_fd"] "src/signalfd.mllib";
         Pkg.clib "src/libsignalfd_stubs.clib" ;
         Pkg.test "test/test"; ]
