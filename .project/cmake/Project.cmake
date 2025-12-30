set(FI_PROJECT_CMAKE_DIR ${CMAKE_CURRENT_LIST_DIR})
include(${FI_PROJECT_CMAKE_DIR}/Utility.cmake)
include(${FI_PROJECT_CMAKE_DIR}/Import.cmake)
include(${FI_PROJECT_CMAKE_DIR}/Folder.cmake)


# 导入本地设置变量
if(EXISTS ${CMAKE_SOURCE_DIR}/fi_local.cmake)
    include(${CMAKE_SOURCE_DIR}/fi_local.cmake)
endif()

cmake_path(GET CMAKE_SOURCE_DIR STEM FI_PROJECT_NAME)

fi_set_git_vars()

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
set(CMAKE_EXPORT_PACKAGE_DEPENDENCIES ON)
set(CMAKE_FIND_PACKAGE_PREFER_CONFIG ON)
set(QT_QML_GENERATE_QMLLS_INI ON)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

if(APPLE)
    # set(CMAKE_OSX_DEPLOYMENT_TARGET "26.0")
    set(CMAKE_OSX_ARCHITECTURES "arm64")
endif()

macro(fi_project)
    cmake_parse_arguments(
        FI_PROJECT
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
    if(FI_PROJECT_TESTING)
        set(ENABLE_TESTING ${FI_PROJECT_TESTING})
    endif()

    if(FI_PROJECT_STATIC)
        set(BUILD_SHARED_LIBS OFF)
    else()
        set(BUILD_SHARED_LIBS ON)
    endif()

    if(FI_PROJECT_RELEASE)
        set(CMAKE_BUILD_TYPE "Release")
    else()
        set(CMAKE_BUILD_TYPE "Debug")
    endif()
    if(FI_PROJECT_INSTALL_PATH)
        fi_set_install_prefix(
            "${FI_PROJECT_INSTALL_PATH}"
            "${CMAKE_SOURCE_DIR}/.install/${PROJECT_VERSION}/${CMAKE_BUILD_TYPE}/"
        )
    endif()

    if(ENABLE_TESTING)
        message("单元测试: 开启")
        enable_testing()
        include(CTest)
        if(Catch2_FOUND)
            include(Catch)
        else()
            message("================================================")
            message("警告: 未导入Catch2, 无法使用Catch相关功能")
        endif()
    endif()

    fi_add_subfolder()

    message("================================================")
    message("${PROJECT_NAME} ${PROJECT_VERSION} 配置完成")
    message("代码基点: 分支 ${FI_GIT_BRANCH} 第 ${FI_GIT_COMMIT_COUNT} 次提交 ${FI_GIT_HASH}")

    if(ENABLE_TESTING)
        message("单元测试: 开启")
    else()
        message("单元测试: 关闭")
    endif()
    if(BUILD_SHARED_LIBS)
        message("构建类型: ${CMAKE_BUILD_TYPE} 动态库")
    else()
        message("构建类型: ${CMAKE_BUILD_TYPE}静态库")
    endif()
    message("构建位置: ${CMAKE_BINARY_DIR}")
    message("安装位置: ${CMAKE_INSTALL_PREFIX}")
    message("================================================")
endmacro()
