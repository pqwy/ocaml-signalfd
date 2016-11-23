(* Copyright (c) 2015-2016 David Kaloper Meršinjak. All rights reserved.
   See LICENSE.md. *)

let sigrtmin = Sigset.sigrtmin ()
let sigrtmax = Sigset.sigrtmax ()

let sfailwith fmt = Printf.ksprintf failwith fmt

external sigqueue : pid:int -> sgn:int -> value:int -> unit = "caml_sigqueue"

external sigprocmask : int -> Sigset.t -> Sigset.t = "caml_sigprocmask"

let sigprocmask mode signals =
  sigprocmask
    ( match mode with `Block -> 0 | `Unblock -> 1 | `Setmask -> 2 )
    (Sigset.of_list signals) |> Sigset.to_list

module Siginfo_t = struct

  external sizeof_siginfo : unit -> int = "caml_sizeof_signalfd_siginfo"
  let size = sizeof_siginfo ()

  type t = {
    signo   : int    (** Signal number *)
                     (*  Error number (unused) *)
  ; code    : int    (** Signal code *)
  ; pid     : int    (** PID of sender *)
  ; uid     : int    (** Real UID of sender *)
  ; fd      : int    (** File descriptor (SIGIO) *)
  ; tid     : int    (** Kernel timer ID (POSIX timers) *)
  ; band    : int    (** Band event (SIGIO) *)
  ; overrun : int    (** POSIX timer overrun count *)
  ; trapno  : int    (** Trap number that caused signal *)
  ; status  : int    (** Exit status or signal (SIGCHLD) *)
  ; int     : int    (** Integer sent by sigqueue(3) *)
  ; ptr     : int64  (** Pointer sent by sigqueue(3) *)
  ; utime   : int64  (** User CPU time consumed (SIGCHLD) *)
  ; stime   : int64  (** System CPU time consumed (SIGCHLD) *)
  ; addr    : int64  (** Address that generated signal (for hardware-generated signals) *)
  }

  module NE = EndianBytes.NativeEndian

  module Decode = struct

    type t = { buf : bytes ; mutable off : int }

    let create ?(off=0) buf = { off; buf }

    let i32 ({ off; _ } as t) =
      t.off <- off + 4 ; NE.get_int32 t.buf off

    let i64 ({ off; _ } as t) =
      t.off <- off + 8 ; NE.get_int64 t.buf off

    let i32n t = i32 t |> Int32.to_int
  end

  let from_buffer ?(off=0) buf =
    let open Decode in
    let d = create ~off buf in
    let signo   = i32n d
    and _       = i32n d
    and code    = i32n d
    and pid     = i32n d
    and uid     = i32n d
    and fd      = i32n d
    and tid     = i32n d
    and band    = i32n d
    and overrun = i32n d
    and trapno  = i32n d
    and status  = i32n d
    and int     = i32n d
    and ptr     = i64 d
    and utime   = i64 d
    and stime   = i64 d
    and addr    = i64 d
    in {
      signo; code; pid; uid; fd; tid; band; overrun
    ; trapno; status; int; ptr; utime; stime; addr
    }

  let i32 buf i = NE.get_int32 buf i |> Int32.to_int

  let get_signo buf = i32 buf 0
  and get_code  buf = i32 buf 8
  and get_pid   buf = i32 buf 12
  and get_uid   buf = i32 buf 16
  and get_int   buf = i32 buf 44

end

external signalfd : Unix.file_descr -> Sigset.t -> int -> Unix.file_descr = "caml_signalfd"

let set_mask fd sgn = signalfd fd (Sigset.of_list sgn) 0 |> ignore

let signalfd ?(nonblock=false) ?(cloexec=false) sgn =
  let f = if nonblock then 1 else 0 in
  let f = if cloexec then 3 lor f else f in
  signalfd (Obj.magic(-1)) (Sigset.of_list sgn) f

let dequeue =
  let x   = Siginfo_t.size in
  let buf = Bytes.create x in fun fd ->
    let n = Unix.read fd buf 0 x in
    if n = x then Siginfo_t.from_buffer buf
    else if n = 0 then
      invalid_arg "dequeue: signal not ready"
    else sfailwith "dequeue: read returned %d bytes" n
