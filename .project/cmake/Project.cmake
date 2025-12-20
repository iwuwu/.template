include(${CMAKE_CURRENT_LIST_DIR}/Utility.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/Import.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/Install.cmake)


# 导入本地设置变量
if(EXISTS ${CMAKE_SOURCE_DIR}/.fi_local)
    include(${CMAKE_SOURCE_DIR}/.fi_local)
endif()

cmake_path(GET CMAKE_SOURCE_DIR STEM fi_root_name)

fi_git_info()

message("================================================")
message("${fi_root_name} ${fi_git_version} 配置开始")
message("${fi_git_branch} 分支第 ${fi_git_commit_count} 次提交: ${fi_git_hash}")
message("================================================")

# 设置项目变量
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
    # 编译和启用测试, 注意在宏中传变量名和变量值的区别
    fi_enable_testing(ENABLE_TESTING)
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

    #顶层配置结束，添加子目录
    # fi_add_all_subfolders()

    message("================================================")
    message("项目配置完成")
    message("================================================")
endmacro()
