#include "common.h"


#define error_signal(f, x) \
  (uerror (f, caml_alloc_sprintf ("signal: %d", Int_val (x))))

static struct custom_operations sigset_ops = {
  "_sigset",
  custom_finalize_default,
  custom_compare_default,
  custom_hash_default,
  custom_serialize_default,
  custom_deserialize_default,
  custom_compare_ext_default
};

CAMLprim value caml_rts_new_sigset (value unit) {
  CAMLparam1 (unit);
  CAMLlocal1 (ss);
  ss = caml_alloc_custom (&sigset_ops, sizeof (sigset_t), 0, 1);
  sigemptyset (_ss_set (ss));
  CAMLreturn (ss);
}

CAMLprim value caml_rts_sigemptyset (value ss) {
  sigemptyset (_ss_set (ss));
  return Val_unit;
}

CAMLprim value caml_rts_sigaddset (value ss, value x) {
  CAMLparam2 (ss, x);
  if (sigaddset (_ss_set (ss), Int_val (x)) == -1)
    error_signal ("sigaddset", x);
  CAMLreturn (Val_unit);
}

CAMLprim value caml_rts_sigismember (value ss, value x) {
  CAMLparam2 (ss, x);
  switch (sigismember (_ss_set (ss), Int_val (x))) {
    case 0: CAMLreturn (Val_false);
    case 1: CAMLreturn (Val_true);
  }
  error_signal ("sigismember", x);
}

CAMLprim value caml_rts_sigrtmin (value unit) {
  return Val_int (SIGRTMIN);
}

CAMLprim value caml_rts_sigrtmax (value unit) {
  return Val_int (SIGRTMAX);
}
