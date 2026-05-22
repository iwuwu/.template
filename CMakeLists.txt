cmake_minimum_required(VERSION ${CMAKE_VERSION})
project(Fi VERSION 1.0.0 LANGUAGES CXX)

include(.project/cmake/Project.cmake)

fi_import(
    Qt6
    COMPONENTS Core Qml Gui Quick QuickTest
)
fi_import(Catch2)
fi_import(SQLite3)
fi_import(ExprTk)

fi_project()






