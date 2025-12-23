include(${fi_project_cmake_dir}/File.cmake)
include(${fi_project_cmake_dir}/Target.cmake)
include(${fi_project_cmake_dir}/Install.cmake)

# 这里输入的相对于项目根目录的名称（可接受各种分隔符）
function(fi_add_folder paths)
    if(paths)
        foreach(path IN LISTS paths)
            # #号开头的视为注释掉了的文件夹，不参与编译，当在DEPNDS里给出时自然忽略掉了
            if(path MATCHES "^#")
                continue()
            endif()
            string(REGEX REPLACE "[:._]+" "/" path ${path})
            set(full_path "${CMAKE_SOURCE_DIR}/${path}")
            if(NOT EXISTS "${full_path}/CMakeLists.txt")
                continue()
            endif()
            # 利用全局变量记录已经添加了的路径
            get_property(added_folders GLOBAL PROPERTY fi_added_folders)
            if(${path} IN_LIST added_folders)
                continue()
            endif()
            add_subdirectory("${full_path}" "${CMAKE_BINARY_DIR}/${path}")
            set_property(GLOBAL APPEND PROPERTY fi_added_folders ${path})
        endforeach()
    endif()
endfunction()

function(fi_add_subfolder)
    # 这里只会产生当前下一级目录的目录名的相对项目根目录的路径
    file(GLOB paths RELATIVE ${CMAKE_SOURCE_DIR} LIST_DIRECTORIES true CONFIGURE_DEPENDS "*")
    fi_add_folder("${paths}")
endfunction()

function(fi_folder)
    cmake_parse_arguments(PARSE_ARGV
        0
        fi_folder
        "PROJECT;QML;LIB;EXE"
        "VERSION;TEST"
        "PUBLIC;PRIVATE;INTERFACE;DEPENDS;IMPORTS"
    )

    cmake_path(RELATIVE_PATH CMAKE_CURRENT_SOURCE_DIR BASE_DIRECTORY ${CMAKE_SOURCE_DIR} OUTPUT_VARIABLE fi_folder_path)
    if(NOT fi_folder_path)
        return()
    endif()

    cmake_path(GET fi_folder_path STEM fi_folder_last_name)
    string(REPLACE "/" "." fi_folder_uri ${fi_folder_path})
    string(REPLACE "/" "_" fi_folder_name ${fi_folder_path})
    string(REPLACE "/" "::" fi_folder_namespace ${fi_folder_path})
    string(REPLACE "/" "" fi_folder_camel_name ${fi_folder_path})
    string(TOUPPER "${fi_folder_name}" fi_folder_upper_name)

    cmake_path(GET fi_folder_path PARENT_PATH fi_folder_parent_path)
    if(fi_folder_parent_path)
        cmake_path(GET fi_folder_parent_path STEM fi_folder_parent_last_name)
        string(REPLACE "/" "." fi_folder_parent_uri ${fi_folder_parent_path})
        string(REPLACE "/" "_" fi_folder_parent_name ${fi_folder_parent_path})
        string(REPLACE "/" "::" fi_folder_parent_namespace ${fi_folder_parent_path})
        string(REPLACE "/" "" fi_folder_parent_camel_name ${fi_folder_parent_path})
        string(TOUPPER "${fi_folder_parent_name}" fi_folder_parent_upper_name)
    endif()

    fi_set_folder_files()

    if(NOT fi_folder_VERSION)
        set(fi_folder_version ${PROJECT_VERSION})
    endif()

    if(fi_folder_PROJECT)
        project(${fi_folder_name} VERSION ${fi_folder_version} LANGUAGES CXX)
    endif()

    if(fi_folder_QML)
        # 编译Qml Module时，DEPENDS和IMPORTS的目标必须先于本目标存在
        if(fi_folder_DEPENDS)
            fi_add_folder("${fi_folder_DEPENDS}")
        endif()
        if(fi_folder_IMPORTS)
            fi_add_folder("${fi_folder_IMPORTS}")
        endif()
        fi_add_qml()
    endif()

    if(fi_folder_LIB AND NOT fi_folder_QML)
        fi_add_lib()
    endif()

    if(fi_folder_EXE AND NOT fi_folder_LIB)
        fi_add_exe()
    endif()

    if(DEFINED fi_folder_TEST AND ENABLE_TESTING AND NOT fi_folder_EXE AND NOT fi_folder_LIB)
        fi_add_test("${fi_folder_TEST}")
    endif()

    message("${fi_folder_targets}")
    fi_install("${fi_folder_targets}")
    unset(fi_folder_targets)
    fi_add_subfolder()
endfunction()

