cmake_minimum_required(VERSION ${CMAKE_VERSION})
include(.project/cmake/Project.cmake)

project(${FI_PROJECT_NAME} VERSION ${FI_GIT_VERSION} LANGUAGES CXX)

fi_import(
    Qt6
    COMPONENTS Core Qml Gui Quick QuickTest
)
fi_import(Catch2)
fi_project()




