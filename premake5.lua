workspace "Lua"
    configurations {"release", "debug"}
    platforms { "Windows", "Wasm" }
    targetdir "build"
    architecture "amd64"
    cppdialect "C++17"

    filter "configurations:debug"
        runtime  "debug"
        symbols  "on"
        optimize "off"
        defines { "DEBUG" }

    filter "configurations:release"
        runtime  "release"
        symbols  "off"
        optimize "speed"
        defines { "NDEBUG" }


    project "LuaExe"
        language "C"
        kind "ConsoleApp"
        staticruntime "on"
        removeconfigurations "debug"
        files { "lua/src/lua.c" }
        includedirs { "lua/src" }
        targetname "lua"
        links {"Lua"}
        filter "platforms:Windows"
            system "windows"
            targetdir "build/tools"
    project "LuaC"
        language "C"
        kind "ConsoleApp"
        staticruntime "on"
        removeconfigurations "debug"
        files { "lua/src/luac.c" }
        includedirs { "lua/src" }
        targetname "luac"
        links {"Lua"}
        filter "platforms:Windows"
            system "windows"
            targetdir "build/tools"

    project "Lua"
        language "C"
        kind "StaticLib"
        staticruntime "on"
        targetdir "build/%{cfg.platform}/%{cfg.buildcfg}"
        files { "**.c", "**.h" }
        --Remove lua.c and lua.c since we are building a library
        removefiles { "**lua.c", "**luac.c" }

        filter "toolset:msc"
            targetextension  ".lib"
        filter "toolset:gcc"
            targetprefix "lib"
            targetextension  ".a" 

        filter "platforms:Windows"
            system "windows"
            defines{"_WIN32"}
            postbuildcommands {
                "@echo off & if not exist build\\include mkdir build\\include",
                "{COPY} lua/src/lua.h build/include/",
                "{COPY} lua/src/lauxlib.h build/include/",
                "{COPY} lua/src/lualib.h build/include/",
                "{COPY} lua/src/luaconf.h build/include/",
            }
        filter "platforms:wasm"
            system "emscripten"
            optimize "speed"
            architecture "wasm32"
            -- i cannot get this to work since the ENV modifications are not carried over to the compile step!
            -- prebuildcommands {"if \"%EMSDK%\"==\"\" C:\\Compiler\\emsdk\\emsdk_env.bat"}
            -- prebuildcommands {"@echo off & if \"%EMSDK%\"==\"\" call c:\\Compiler\\emsdk\\emsdk construct_env"}
            prebuildcommands {"@echo off & if \"%EMSDK%\"==\"\" echo you must setup the emsdk environment!"}
            postbuildcommands {
                "@echo off & if not exist build\\include mkdir build\\include",
                "{COPY} lua/src/lua.h build/include/",
                "{COPY} lua/src/lauxlib.h build/include/",
                "{COPY} lua/src/lualib.h build/include/",
                "{COPY} lua/src/luaconf.h build/include/",
            }
    
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
