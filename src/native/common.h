#include <signal.h>

#include <caml/memory.h>
#include <caml/custom.h>
#include <caml/alloc.h>
#include <caml/unixsupport.h>


#define _ss_set(ss) ((sigset_t *)(Data_custom_val(ss)))

CAMLprim value caml_rts_new_sigset (value unit);
