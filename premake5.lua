workspace "Lua"
    configurations {"Release"}
    platforms { "Windows", "Wasm" }
    project "Lua"
        language "C"
        kind "StaticLib"
        staticruntime "on"
        architecture "amd64"

        files { "**.c", "**.h" }
        --Remove lua.c and lua.c since we are building a library
        removefiles { "**lua.c", "**luac.c" }

        filter "platforms:Windows"
            system "windows"
            targetdir "build/windows"
            postbuildcommands {
                "@echo off & if not exist build\\include mkdir build\\include",
                "{COPY} lua/src/lua.h build/include/",
                "{COPY} lua/src/lauxlib.h build/include/",
                "{COPY} lua/src/lualib.h build/include/",
            }
        filter "platforms:Wasm"
            system "emscripten"
            optimize "speed"
            architecture "wasm32"
            targetdir "build/wasm"
            -- i cannot get this to work since the ENV modifications are not carried over to the compile step!
            -- prebuildcommands {"if \"%EMSDK%\"==\"\" C:\\Compiler\\emsdk\\emsdk_env.bat"}
            -- prebuildcommands {"@echo off & if \"%EMSDK%\"==\"\" call c:\\Compiler\\emsdk\\emsdk construct_env"}
            prebuildcommands {"@echo off & if \"%EMSDK%\"==\"\" echo you must setup the emsdk environment!"}
            postbuildcommands {
                "@echo off & if not exist build\\include mkdir build\\include",
                "{COPY} lua/src/lua.h build/include/",
                "{COPY} lua/src/lauxlib.h build/include/",
                "{COPY} lua/src/lualib.h build/include/",
            }
        filter "configurations:*"
            runtime "Release"    
            optimize "speed"
            defines { "NDEBUG"} --, "_WIN32" }
    
    
        newaction {
            trigger = "clean",
            description = "clean the project",
            execute = function()
                os.rmdir("obj")
                os.rmdir("build")
                os.remove("Makefile")
                os.remove("Lua.Make")
            end
        }
