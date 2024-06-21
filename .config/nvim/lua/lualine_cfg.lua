
local cmake = require("cmake-tools")
local icons = require("icons")

return {
    macro = function()
        local reg = vim.fn.reg_recording()
        if (reg ~= '') then
            return '@' .. reg
        else
            return ''
        end
    end,
    cmake_preset = {
        function()
            local c_preset = cmake.get_configure_preset()
            return "CMake: [" .. (c_preset and c_preset or "X") .. "]"
        end,
        icon = icons.ui.Search,
        cond = function()
            return cmake.is_cmake_project() and cmake.has_cmake_preset()
        end,
        on_click = function(n, mouse)
            if (n == 1) then
                if (mouse == "l") then
                    vim.cmd("CMakeSelectConfigurePreset")
                end
            end
        end
    },

    cmake_type = {
        function()
            local type = cmake.get_build_type()
            return "CMake: [" .. (type and type or "") .. "]"
        end,
        icon = icons.ui.Search,
        cond = function()
            return cmake.is_cmake_project() and not cmake.has_cmake_preset()
        end,
        on_click = function(n, mouse)
            if (n == 1) then
                if (mouse == "l") then
                    vim.cmd("CMakeSelectBuildType")
                end
            end
        end
    },

    cmake_kit = {
        function()
            local kit = cmake.get_kit()
            return "[" .. (kit and kit or "X") .. "]"
        end,
        icon = icons.ui.Pencil,
        cond = function()
            return cmake.is_cmake_project() and not cmake.has_cmake_preset()
        end,
        on_click = function(n, mouse)
            if (n == 1) then
                if (mouse == "l") then
                    vim.cmd("CMakeSelectKit")
                end
            end
        end
    },
    cmake_build = {
        function()
            return "Build"
        end,
        icon = icons.ui.Gear,
        cond = cmake.is_cmake_project,
        on_click = function(n, mouse)
            if (n == 1) then
                if (mouse == "l") then
                    vim.cmd("CMakeBuild")
                end
            end
        end
    },
    cmake_build_preset = {
        function()
            local b_preset = cmake.get_build_preset()
            return "[" .. (b_preset and b_preset or "X") .. "]"
        end,
        icon = icons.ui.Search,
        cond = function()
            return cmake.is_cmake_project() and cmake.has_cmake_preset()
        end,
        on_click = function(n, mouse)
            if (n == 1) then
                if (mouse == "l") then
                    vim.cmd("CMakeSelectBuildPreset")
                end
            end
        end
    },
    cmake_build_target = {
        function()
            local b_target = cmake.get_build_target()
            return "[" .. (b_target and b_target or "X") .. "]"
        end,
        cond = cmake.is_cmake_project,
        on_click = function(n, mouse)
            if (n == 1) then
                if (mouse == "l") then
                    vim.cmd("CMakeSelectBuildTarget")
                end
            end
        end
    },
    cmake_debug = {
        function()
            return icons.ui.Debug
        end,
        cond = cmake.is_cmake_project,
        on_click = function(n, mouse)
            if (n == 1) then
                if (mouse == "l") then
                    vim.cmd("CMakeDebug")
                end
            end
        end
    },
    cmake_run = {
        function()
            return icons.ui.Run
        end,
        cond = cmake.is_cmake_project,
        on_click = function(n, mouse)
            if (n == 1) then
                if (mouse == "l") then
                    vim.cmd("CMakeRun")
                end
            end
        end
    },
    cmake_launch_target = {
        function()
            local l_target = cmake.get_launch_target()
            return "[" .. (l_target and l_target or "X") .. "]"
        end,
        cond = cmake.is_cmake_project,
        on_click = function(n, mouse)
            if (n == 1) then
                if (mouse == "l") then
                    vim.cmd("CMakeSelectLaunchTarget")
                end
            end
        end
    }
}
