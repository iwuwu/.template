function(fi_has_git path return)
    find_package(Git QUIET)
    if(NOT Git_FOUND)
        message("警告: 没有安装Git, 无法使用Git相关功能")
        return()
    endif()
    execute_process(
        COMMAND ${GIT_EXECUTABLE} rev-parse --is-inside-work-tree
        WORKING_DIRECTORY ${path}
        OUTPUT_VARIABLE ${return}
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
    )
    set(${return} ${${return}} PARENT_SCOPE)
endfunction()

function(fi_git_tag path return)
    fi_has_git(${path} has_git)
    if(NOT has_git)
        message("警告: 没有Git仓库, 无法使用Git相关功能")
        return()
    endif()
    execute_process(
        COMMAND ${GIT_EXECUTABLE} describe --tags --always --dirty
        WORKING_DIRECTORY ${path}
        OUTPUT_VARIABLE ${return}
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
    )
    set(${return} ${${return}} PARENT_SCOPE)
endfunction()

function(fi_git_version path return)
    fi_git_tag(${path} ${return})
    #限定最多4位版本号，但cmake不支持{n,m}
    string(REGEX MATCH "[0-9]+(\\.[0-9])?(\\.[0-9])?(\\.[0-9])?" ${return} ${${return}})
    if(NOT return)
        message("警告: 无法从Tag信息中提取版本号")
        set(${return} 0 PARENT_SCOPE)
    endif()
    set(${return} ${${return}} PARENT_SCOPE)
endfunction()




