include(${FI_PROJECT_CMAKE_DIR}/File.cmake)
include(${FI_PROJECT_CMAKE_DIR}/Target.cmake)
include(${FI_PROJECT_CMAKE_DIR}/Install.cmake)

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
    cmake_policy(SET CMP0174 NEW)
    cmake_parse_arguments(PARSE_ARGV
        0
        FI_FOLDER
        "PROJECT;QML;LIB;EXE"
        "VERSION;TEST"
        "PUBLIC;PRIVATE;INTERFACE;DEPENDS;IMPORTS"
    )

    cmake_path(RELATIVE_PATH CMAKE_CURRENT_SOURCE_DIR BASE_DIRECTORY ${CMAKE_SOURCE_DIR} OUTPUT_VARIABLE FI_FOLDER_PATH)
    if(NOT FI_FOLDER_PATH)
        return()
    endif()

    cmake_path(GET FI_FOLDER_PATH STEM FI_FOLDER_LAST_NAME)
    string(REPLACE "/" "." FI_FOLDER_URI ${FI_FOLDER_PATH})
    string(REPLACE "/" "_" FI_FOLDER_NAME ${FI_FOLDER_PATH})
    string(REPLACE "/" "::" FI_FOLDER_NAMESPACE ${FI_FOLDER_PATH})
    string(REPLACE "/" "" FI_FOLDER_CAMEL_NAME ${FI_FOLDER_PATH})
    string(TOUPPER "${FI_FOLDER_NAME}" FI_FOLDER_UPPER_NAME)

    cmake_path(GET FI_FOLDER_PATH PARENT_PATH FI_FOLDER_PARENT_PATH)
    if(FI_FOLDER_PARENT_PATH)
        cmake_path(GET FI_FOLDER_PARENT_PATH STEM FI_FOLDER_PARENT_LAST_NAME)
        string(REPLACE "/" "." FI_FOLDER_PARENT_URI ${FI_FOLDER_PARENT_PATH})
        string(REPLACE "/" "_" FI_FOLDER_PARENT_NAME ${FI_FOLDER_PARENT_PATH})
        string(REPLACE "/" "::" FI_FOLDER_PARENT_NAMESPACE ${FI_FOLDER_PARENT_PATH})
        string(REPLACE "/" "" FI_FOLDER_PARENT_CAMEL_NAME ${FI_FOLDER_PARENT_PATH})
        string(TOUPPER "${FI_FOLDER_PARENT_NAME}" FI_FOLDER_PARENT_UPPER_NAME)
    endif()

    fi_set_folder_files()

    if(NOT FI_FOLDER_VERSION MATCHES "[0-9]+(\\.[0-9]+)+")
        set(FI_FOLDER_VERSION ${PROJECT_VERSION})
    endif()

    message("================================================")

    if(FI_FOLDER_PROJECT)
        project(${FI_FOLDER_NAME} VERSION ${FI_FOLDER_VERSION} LANGUAGES CXX)
    endif()

    message("./${FI_FOLDER_PATH}")
    # string(LENGTH "./${FI_FOLDER_PATH}" n)
    # string(REPEAT "-" ${n} h)
    # message(${h})
    # message("")
    # message("PROJECT ${PROJECT_NAME} ${PROJECT_VERSION}")
    # message("")


    if(FI_FOLDER_QML)
        # 编译Qml Module时，DEPENDS和IMPORTS的目标必须先于本目标存在
        if(FI_FOLDER_DEPENDS)
            fi_add_folder("${FI_FOLDER_DEPENDS}")
        endif()
        if(FI_FOLDER_IMPORTS)
            fi_add_folder("${FI_FOLDER_IMPORTS}")
        endif()

        fi_add_qml("_${FI_FOLDER_NAME}_")

    elseif(FI_FOLDER_LIB)
        fi_add_lib("_${FI_FOLDER_NAME}_")
    endif()

    if(DEFINED FI_FOLDER_TEST AND ENABLE_TESTING)
        fi_add_test("${FI_FOLDER_NAME}" "${FI_FOLDER_TEST}")
    elseif(FI_FOLDER_EXE)
        fi_add_exe("${FI_FOLDER_NAME}")
    endif()

    fi_install("${FI_FOLDER_TARGETS}")
    unset(FI_FOLDER_TARGETS)
    fi_add_subfolder()
endfunction()

