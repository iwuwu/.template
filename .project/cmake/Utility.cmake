macro(fi_clear_vars prefix)
    get_cmake_property(fi_variable_names VARIABLES)
    list(FILTER fi_variable_names INCLUDE REGEX "${prefix}.*")
    foreach(var IN LISTS fi_variable_names)
        unset(${var})
    endforeach()
    unset(fi_variable_names)
endmacro()

# 可以给出一系列路径，选出第一个可用路径设置
function(fi_set_install_prefix)
    foreach(path IN LISTS ARGV)
        cmake_path(SET path NORMALIZE "${path}")
        cmake_path(IS_ABSOLUTE path is_vaild)
        if(is_vaild)
            set(CMAKE_INSTALL_PREFIX "${path}" PARENT_SCOPE)
            return()
        endif()
    endforeach()
endfunction()


# 这里查询次数太多了，可改成一次查询
macro(fi_get_git_vars)
    find_package(Git QUIET)
    if(Git_FOUND)
        # 检查是否为Git仓库
        execute_process(
            COMMAND ${GIT_EXECUTABLE} rev-parse --is-inside-work-tree
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
            OUTPUT_VARIABLE fi_git_is_repo
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
        )
        if(fi_git_is_repo)
            # 获取Git描述（版本信息）
            execute_process(
                COMMAND ${GIT_EXECUTABLE} describe --tags --always --dirty
                WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                OUTPUT_VARIABLE fi_git_tag
                OUTPUT_STRIP_TRAILING_WHITESPACE
                ERROR_QUIET
            )

            string(REGEX MATCH "[0-9]+(\\.[0-9])?(\\.[0-9])?(\\.[0-9])?" fi_git_version ${fi_git_tag})
            if(NOT fi_git_version)
                message("无法从Tag信息中提取版本号, 默认为0")
            endif()


            # 获取提交哈希
            execute_process(
                COMMAND ${GIT_EXECUTABLE} rev-parse --short HEAD
                WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                OUTPUT_VARIABLE fi_git_hash
                OUTPUT_STRIP_TRAILING_WHITESPACE
                ERROR_QUIET
            )
            # 获取分支名称
            execute_process(
                COMMAND ${GIT_EXECUTABLE} rev-parse --abbrev-ref HEAD
                WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                OUTPUT_VARIABLE fi_git_branch
                OUTPUT_STRIP_TRAILING_WHITESPACE
                ERROR_QUIET
            )
            # 获取完整提交哈希（可选）
            execute_process(
                COMMAND ${GIT_EXECUTABLE} rev-parse HEAD
                WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                OUTPUT_VARIABLE fi_gi_full_hash
                OUTPUT_STRIP_TRAILING_WHITESPACE
                ERROR_QUIET
            )
            # 获取提交计数（构建号）
            execute_process(
                COMMAND ${GIT_EXECUTABLE} rev-list --count HEAD
                WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                OUTPUT_VARIABLE fi_git_commit_count
                OUTPUT_STRIP_TRAILING_WHITESPACE
                ERROR_QUIET
            )
        else()
            message("警告: 没有Git仓库, 无法使用Git相关功能")
        endif()
    else()
        message("警告: 没有安装Git, 无法使用Git相关功能")
    endif()
endmacro()

macro(fi_make_header_only_package namespace package_name version path)
    add_library("${package_name}::${package_name}" INTERFACE IMPORTED)
    target_include_directories("${namespace}::${package_name}" INTERFACE
        "${path}"
    )
    set("${package_name}_FOUND" TRUE)
    set("${package_name}_VERSION" ${version})
    set("${package_name}_DIR" "${path}")
endmacro()

macro(fi_make_package namespace package_name version path)
    add_library("${namespace}::${package_name}" UNKNOWN IMPORTED)
    set_target_properties("${namespace}::${package_name}" PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${path}/include/"
        IMPORTED_LOCATION "${path}/lib/"
        IMPORTED_IMPLIB "${path}/lib/"
    )
    set("${package_name}_FOUND" TRUE)
    set("${package_name}_VERSION" ${version})
    set("${package_name}_DIR" "${path}")
endmacro()
