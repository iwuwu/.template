macro(fi_import_by_default package_name)
    message("导入: ${package_name} 使用默认规则搜索")
    if(NOT ${package_name}_FOUND)
        find_package(
            ${package_name}
            ${ARGN}
            QUIET
        )
        if(NOT ${package_name}_FOUND)
            message("失败: 默认规则搜索未找到CMake包配置文件")
        endif()
    endif()
endmacro()

macro(fi_import_by_env_path package_name)
    if(NOT "$ENV{${package_name}_PATH}" STREQUAL "")
        message("导入: ${package_name} 使用环境变量 ${package_name}_PATH: $ENV{${package_name}_PATH}")
        if(IS_DIRECTORY "$ENV{${package_name}_PATH}")
            find_package(
                ${package_name}
                ${ARGN}
                HINTS "$ENV{${package_name}_PATH}"
                NO_DEFAULT_PATH
                QUIET
            )
            if(NOT ${package_name}_FOUND)
                message("失败: 路径中未找到CMake包配置文件")
                fi_import_by_default(${package_name} ${ARGN})
            endif()
        else()
            message("失败: 环境变量给出的路径无效")
            fi_import_by_default(${package_name} ${ARGN})
        endif()
    else()
        fi_import_by_default(${package_name} ${ARGN})
    endif()
endmacro()

macro(fi_import_by_file_path package_name)
    if(${package_name}_PATH)
        message("导入: ${package_name} 使用LOCAL文件变量 ${package_name}_PATH: ${${package_name}_PATH}")
        if(IS_DIRECTORY "${${package_name}_PATH}")
            find_package(
                ${package_name}
                ${ARGN}
                HINTS "${${package_name}_PATH}"
                NO_DEFAULT_PATH
                QUIET
            )
            if(NOT ${package_name}_FOUND)
                message("失败: 路径中未找到CMake包配置文件")
                fi_import_by_env_path(${package_name} ${ARGN})
            endif()
        else()
            message("失败: 文件变量给出的路径无效")
            fi_import_by_env_path(${package_name} ${ARGN})
        endif()
    else()
        fi_import_by_env_path(${package_name} ${ARGN})
    endif()
endmacro()

macro(fi_import_by_path package_name path)
    if(NOT "${path}" STREQUAL "")
        message("导入: ${package_name} 使用直接变量 PATH: ${path}")
        if(IS_DIRECTORY "${path}")
            # 注意:如果之前通过任何方式找到过包，则后续调用会使用之前缓存的各种变量
            find_package(
                ${package_name}
                ${ARGN}
                HINTS "${path}"
                NO_DEFAULT_PATH
                QUIET
            )
            if(NOT ${package_name}_FOUND)
                message("失败: 路径中未找到CMake包配置文件")
                fi_import_by_file_path(${package_name} ${ARGN})
            endif()
        else()
            message("失败: PATH变量给出的路径无效")
            fi_import_by_file_path(${package_name} ${ARGN})
        endif()
    else()
        fi_import_by_file_path(${package_name} ${ARGN})
    endif()
endmacro()

macro(fi_import package_name)
    message("================================================")
    cmake_parse_arguments(
        fi_import
        "DETAILS"
        "PATH"
        ""
        ${ARGN}
    )


    if(${package_name}_FOUND)
        message("导入: ${package_name} 使用LOCAL文件手工导入")
    else()
        get_property(fi_import_targets_before DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY IMPORTED_TARGETS)
        fi_import_by_path("${package_name}" "${fi_import_PATH}" ${fi_import_UNPARSED_ARGUMENTS})
        get_property(fi_import_targets_after DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY IMPORTED_TARGETS)
    endif()

    if(${package_name}_FOUND)
        if(fi_import_targets_after)
            set(fi_import_targets ${fi_import_targets_after})
        else()
            get_property(fi_import_targets DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY IMPORTED_TARGETS)
        endif()

        list(FILTER fi_import_targets INCLUDE REGEX "(${package_name}::.*)|(.*::${package_name}.*)")
        list(SORT fi_import_targets)

        list(REMOVE_ITEM fi_import_targets_after ${fi_import_targets_before})
        list(SORT fi_import_targets_after)

        list(APPEND fi_import_targets ${fi_import_targets_after})
        list(REMOVE_DUPLICATES fi_import_targets)

        get_cmake_property(fi_import_vars VARIABLES)
        list(FILTER fi_import_vars INCLUDE REGEX "^${package_name}_LIB.*")

        if(${package_name}_DIR)
            set(fi_import_package_dir ${${package_name}_DIR})
        elseif(${package_name}_INCLUDE_DIR)
            set(fi_import_package_dir ${${package_name}_INCLUDE_DIR})
        else()

        endif()
        message("成功: ${package_name} ${${package_name}_VERSION} 位于 ${fi_import_package_dir}")

        if(NOT fi_import_DETAILS)
            list(LENGTH fi_import_targets fi_import_targets_len)
            if(fi_import_targets_len GREATER 3)
                list(SUBLIST fi_import_targets 0 3 fi_import_targets)
                list(APPEND fi_import_targets "...")
            endif()

            list(LENGTH fi_import_vars fi_import_vars_len)
            if(fi_import_vars_len GREATER 3)
                list(SUBLIST fi_import_vars 0 3 fi_import_vars)
                list(APPEND fi_import_vars "...")
            endif()

        endif()

        if(fi_import_targets)
            string(REPLACE ";" ", " fi_import_targets "${fi_import_targets}")
            message("目标: ${fi_import_targets}")
        endif()

        if(fi_import_vars)
            string(REPLACE ";" ", " fi_import_vars "${fi_import_vars}")
            message("变量: ${fi_import_vars}")
        endif()
    endif()

    fi_clear_vars(fi_import)
endmacro()
