cmake_minimum_required(VERSION ${CMAKE_VERSION})
project(Fi)

include(.project/cmake/Project.cmake)

fi_import(
    Qt6
    COMPONENTS Core Qml Gui Quick QuickTest
)
fi_import(Catch2)

fi_project()




