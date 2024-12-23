@echo off
call premake5.exe gmake2
call mingw32-make.exe config=release_windows
call mingw32-make.exe config=release_wasm