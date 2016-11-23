# signalfd — HERE BE DRAGONS

%%VERSION%%

# DRAGONS

*Highly* volatile interface to bits of the POSIX realtime signals api
(`sigqueue`), and Linux signal file descriptors (`signalfd`).

Linux-specific. A future library will have a better split between the
posix-generic parts, and the OS-specific facility for pollable signals, allowing
clean switching between `signalfd` and `kqueue`.

*This* is not that future library.

You probably *don't* want to use this.
