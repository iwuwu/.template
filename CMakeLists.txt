include(.project/cmake/Project.cmake)
cmake_minimum_required(VERSION ${CMAKE_VERSION})
project(${FI_PROJECT_NAME} VERSION ${FI_GIT_VERSION} LANGUAGES CXX)

fi_import(
    Qt6
    COMPONENTS Core Qml
)
fi_import(Catch2)
fi_project()




