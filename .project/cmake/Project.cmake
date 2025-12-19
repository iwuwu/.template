include(${CMAKE_CURRENT_LIST_DIR}/Version.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/Import.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/Install.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/Testing.cmake)

if(EXISTS ${CMAKE_SOURCE_DIR}/.fi_local)
    include(${CMAKE_SOURCE_DIR}/.fi_local)
endif()

message("================================================")
message("项目配置开始")

# cmake_policy(SET CMP0048 NEW)
# cmake_policy(SET CMP0011 NEW)
# cmake_policy(SET CMP0177 NEW)
# cmake_policy(SET CMP0167 NEW)
# cmake_policy(SET CMP0174 NEW) #使得复杂参数可以为空

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_FIND_PACKAGE_PREFER_CONFIG ON)
if(APPLE)
    set(CMAKE_OSX_DEPLOYMENT_TARGET "26.0")
    set(CMAKE_OSX_ARCHITECTURES "arm64")
endif()

fi_git_version("${CMAKE_SOURCE_DIR}" fi_version)

macro(fi_project)
    message("================================================")
    cmake_parse_arguments(
        fi_project
        "SHARED;STATIC;TESTING;DEBUG;RELEASE"
        "INSTALL_PATH"
        ""
        ${ARGN}
    )
    
    # 编译和启用测试
    fi_enable_testing(${fi_project_TESTING})

    # 静态动态库
    if(fi_project_STATIC)
        message("链接类型: STATIC")
        set(BUILD_SHARED_LIBS OFF)
    else()
        message("链接类型: SHARED")
        set(BUILD_SHARED_LIBS ON)
    endif()

    
    if(fi_project_RELEASE)
    set(CMAKE_BUILD_TYPE "Release")
    endif()
    message("构建类型: ${CMAKE_BUILD_TYPE}")
    

    message("构建位置: ${CMAKE_BINARY_DIR}")
    # 设置安装根目录
    fi_set_install_prefix(
        "${fi_project_INSTALL_PATH}"
        "${CMAKE_SOURCE_DIR}/.install"
    )

    # 设置项目变量
    if(NOT TARGET Qt6::Core)
        message("================================================")
        message("致命错误: 未导入Qt6::Core, 退出构建")
        message("================================================")
        # 注意，这里的return并不是退出宏，而是在宏展开的地方退出
        return()
    endif()
    if(NOT TARGET Qt6::Qml)
        message("================================================")
        message("致命错误: 未导入Qt6::Qml, 退出构建")
        message("================================================")
        # 注意，这里的return并不是退出宏，而是在宏展开的地方退出
        return()
    endif()
    qt_standard_project_setup(REQUIRES ${Qt6_VERSION})

    message("================================================")
    message("项目配置完成")
    message("================================================")
endmacro()
