(* Copyright (c) 2015-2016 David Kaloper Meršinjak. All rights reserved.
   See LICENSE.md. *)

val sigrtmin : int
val sigrtmax : int

val sigqueue : pid:int -> sgn:int -> value:int -> unit

val sigprocmask : [ `Block | `Unblock | `Setmask ] -> int list -> int list

val signalfd : ?nonblock:bool -> ?cloexec:bool -> int list -> Unix.file_descr
val set_mask : Unix.file_descr -> int list -> unit

module Siginfo_t : sig
  val size : int
  val get_signo : bytes -> int
  val get_code  : bytes -> int
  val get_pid   : bytes -> int
  val get_uid   : bytes -> int
  val get_int   : bytes -> int
end
