set(CMAKE_INSTALL_PREFIX "${CMAKE_SOURCE_DIR}/.install")
set(BUILD_SHARED_LIBS ON)
set(ENABLE_TESTING ON)

if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
    set(Qt6_PATH "/opt/qt/6.10.1/macos")
elseif("${CMAKE_BUILD_TYPE}" STREQUAL "Release")
    set(Qt6_PATH "/opt/qt/6.10.1/macos")
endif()

#可用于直接导入没有cmake config文件，但是有标准安装:include,lib,bin目录的包
#路径为include, lib, bin这些目录所在的目录，即install_prefix
fi_find_package("SQLite" "SQLite3" "3.51.1" "/opt/homebrew/opt/sqlite3/")

#可用于直接导入仅有头文件的库（头文件所在目录）
fi_find_header_only_package("ExprTk" "ExprTk" "0.0.3" "/opt/ExprTk/")

