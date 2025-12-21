set(fi_project_cmake_dir ${CMAKE_CURRENT_LIST_DIR})
include(${fi_project_cmake_dir}/Utility.cmake)
include(${fi_project_cmake_dir}/Import.cmake)
include(${fi_project_cmake_dir}/Module.cmake)


# 导入本地设置变量
if(EXISTS ${CMAKE_SOURCE_DIR}/.fi_local)
    include(${CMAKE_SOURCE_DIR}/.fi_local)
endif()

cmake_path(GET CMAKE_SOURCE_DIR STEM fi_root_name)

fi_get_git_vars()

message("================================================")
message("${fi_root_name} ${fi_git_version} 配置开始")
message("${fi_git_branch} 分支第 ${fi_git_commit_count} 次提交: ${fi_git_hash}")

# 设置项目变量
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

macro(fi_project)
    cmake_parse_arguments(
        fi_project
        "SHARED;STATIC;TESTING;DEBUG;RELEASE"
        "INSTALL_PATH"
        ""
        ${ARGN}
    )

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
        return()
    endif()
    # 需要Qt6进行项目基本设置
    qt_standard_project_setup(REQUIRES ${Qt6_VERSION})

    # 编译和启用测试
    set(ENABLE_TESTING ${fi_project_TESTING})

    if(fi_project_STATIC)
        set(BUILD_SHARED_LIBS OFF)
    else()
        set(BUILD_SHARED_LIBS ON)
    endif()

    if(fi_project_RELEASE)
        set(CMAKE_BUILD_TYPE "Release")
    else()
        set(CMAKE_BUILD_TYPE "Debug")
    endif()

    fi_set_install_prefix(
        "${fi_project_INSTALL_PATH}"
        "${CMAKE_SOURCE_DIR}/.install"
    )

    if(ENABLE_TESTING)
        # include会自动enable_testing, 无需再设置
        include(CTest)
        if(Catch2_FOUND)
            include(Catch)
        else()
            message("警告: 未导入Catch2, 无法使用Catch相关功能")
        endif()
    endif()


    # fi_add_sub_module()

    message("================================================")
    message("项目配置完成")
    if(ENABLE_TESTING)
        message("单元测试: 开启")
    else()
        message("单元测试: 关闭")
    endif()
    if(BUILD_SHARED_LIBS)
        message("构建类型: Shared ${CMAKE_BUILD_TYPE}")
    else()
        message("构建类型: Static ${CMAKE_BUILD_TYPE}")
    endif()
    message("构建位置: ${CMAKE_BINARY_DIR}")
    message("安装位置: ${CMAKE_INSTALL_PREFIX}")
    message("================================================")
endmacro()
