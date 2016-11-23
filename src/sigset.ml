(* Copyright (c) 2015-2016 David Kaloper Meršinjak. All rights reserved.
   See LICENSE.md. *)

type t

external sigrtmin : unit -> int = "caml_rts_sigrtmin"
external sigrtmax : unit -> int = "caml_rts_sigrtmax"

external create : unit -> t = "caml_rts_new_sigset"
external empty  : t -> unit = "caml_rts_sigemptyset"
external add    : t -> int -> unit = "caml_rts_sigaddset"
external mem    : t -> int -> bool = "caml_rts_sigismember"

let of_list xs =
  let ss = create () in
  List.iter (add ss) xs; ss

let to_list ss =
  let rec go acc = function
    | 0 -> acc
    | n -> go (if mem ss n then n :: acc else acc) (pred n) in
  go [] (sigrtmax ())

