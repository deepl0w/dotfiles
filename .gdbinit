# Source all settings from the peda dir.
source /usr/share/pwndbg/gdbinit.py

# When inspecting large portions of code the scrollbar works better than 'less'.
set pagination off

# Keep a history of all the commands typed. Search is possible using ctrl-r.
set history save on
set history filename ~/.gdb_history
set history size 32768
set history expansion on

# Demangle C++ names.
set print asm-demangle
set debuginfod enabled on
