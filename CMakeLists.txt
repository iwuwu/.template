include(.project/cmake/Project.cmake)
cmake_minimum_required(VERSION ${CMAKE_VERSION})
project(${FI_PROJECT_NAME} VERSION ${FI_GIT_VERSION} LANGUAGES CXX)

file(GLOB subs "*")

message("${subs}")

fi_import(
    Qt6
    COMPONENTS Core Qml
)
fi_import(Catch2)
fi_import(SQLite3)
fi_import(Eigen3)
fi_import(Sophus)
fi_import(ExprTk)
fi_import(OpenCV)
fi_import(ITK)
fi_import(VTK)
fi_import(JsonCpp)
fi_import(OpenEXR)

fi_project()




