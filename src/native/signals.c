#include "common.h"
#include <sys/signalfd.h>

CAMLprim value caml_sizeof_signalfd_siginfo (value unit) {
  return Val_int (sizeof (struct signalfd_siginfo));
}

static int sigprocmask_table[] = { SIG_BLOCK, SIG_UNBLOCK, SIG_SETMASK };

CAMLprim value caml_sigprocmask (value mode, value sigset) {
  CAMLparam1 (sigset);
  CAMLlocal1 (oldsigset);
  int how = sigprocmask_table [Int_val(mode)];
  oldsigset = caml_rts_new_sigset (Val_unit);
  if (sigprocmask (how, _ss_set (sigset), _ss_set (oldsigset)) == -1) {
    uerror ("sigprocmask", Nothing);
  }
  CAMLreturn (oldsigset);
}

CAMLprim value caml_signalfd (value vfd, value sigset, value vflags) {
  CAMLparam3 (vfd, sigset, vflags);
  int fd = Int_val (vfd), iflags = Int_val (vflags), res = 0, flags = 0;
  if (iflags & 1) flags |= SFD_NONBLOCK;
  if (iflags & 3) flags |= SFD_CLOEXEC;
  if ((res = signalfd (fd, _ss_set (sigset), flags)) == -1)
    uerror ("signalfd", Nothing);
  CAMLreturn (Val_int (res));
}

CAMLprim value caml_sigqueue (value vpid, value vsig, value vv) {
  CAMLparam3 (vpid, vsig, vv);
  int pid = Int_val (vpid), sig = Int_val (vsig), v = Int_val (vv);
  if (sigqueue (pid, sig, (union sigval) v) == -1)
    uerror ("sigqueue", caml_alloc_sprintf ("pid: %d, signal: %d, value: %d", pid, sig, v));
  CAMLreturn (Val_unit);
}
