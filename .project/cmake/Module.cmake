include(${fi_project_cmake_dir}/File.cmake)
include(${fi_project_cmake_dir}/Target.cmake)
include(${fi_project_cmake_dir}/Install.cmake)

# 这里输入的相对于项目根目录的名称（可接受各种分隔符）
function(fi_add_module paths)
    if(paths)
        foreach(path IN LISTS paths)
            # #号开头的视为注释掉了的文件夹，不参与编译，当在DEPNDS里给出时自然忽略掉了
            if(path MATCHES "^#")
                continue()
            endif()
            string(REGEX REPLACE "[:._]+" "/" path ${path})
            set(full_path "${CMAKE_SOURCE_DIR}/${path}")
            if(NOT IS_DIRECTORY full_path)
                continue()
            endif()
            if(NOT EXISTS "${full_path}/CMakeLists.txt")
                continue()
            endif()

            # 利用全局变量记录已经添加了的路径
            get_property(added_path GLOBAL PROPERTY "fi_module_added")
            if(${path} IN_LIST added_path)
                continue()
            endif()
            add_subdirectory("${full_path}" "${CMAKE_BINARY_DIR}/${path}")
            set_property(GLOBAL APPEND fi_module_added ${path})
        endforeach()
    endif()
endfunction()

function(fi_add_sub_module)
    # 这里只会产生当前下一级目录的目录名的相对项目根目录的路径
    file(GLOB paths RELATIVE ${CMAKE_SOURCE_DIR} LIST_DIRECTORIES true CONFIGURE_DEPENDS "*")
    fi_add_module("${paths}")
endfunction()

function(fi_module)
    cmake_parse_arguments(PARSE_ARGV
        0
        fi_module
        "PROJECT;QML;LIB;EXE"
        "VERSION;TEST"
        "PUBLIC;PRIVATE;INTERFACE;DEPENDS;IMPORTS"
    )

    cmake_path(RELATIVE_PATH CMAKE_CURRENT_SOURCE_DIR BASE_DIRECTORY ${CMAKE_SOURCE_DIR} OUTPUT_VARIABLE fi_module_path)
    if(fi_module_path)
        cmake_path(GET fi_module_path STEM fi_module_last_name PARENT_PATH fi_module_parent_path)
        string(REPLACE "/" "." fi_module_uri ${fi_module_path})
        string(REPLACE "/" "_" fi_module_target ${fi_module_path})
        string(REPLACE "/" "::" fi_module_namespace ${fi_module_path})
        string(REPLACE "/" "" fi_module_camel_name ${fi_module_path})
        string(TOUPPER "${fi_module_target}" fi_module_upper_target)
        if(fi_module_parent_path)

        endif()
    else()
        return()
    endif()
    fi_set_module_files()

    if(fi_module_QML)
        if(fi_module_DEPENDS)
            fi_add_module("${fi_module_DEPENDS}")
        endif()
        if(fi_module_IMPORTS)
            fi_add_module("${fi_module_IMPORTS}")
        endif()
        fi_add_qml_module()
    endif()

    if(fi_module_LIB AND NOT fi_module_QML)
        fi_add_lib()
    endif()

    if(fi_module_EXE)
        fi_add_exe()
    endif()

    if(DEFINED fi_module_TEST AND ENABLE_TESTING)
        fi_add_test(${fi_module_TEST})
    endif()

    fi_add_sub_module()
endfunction()

