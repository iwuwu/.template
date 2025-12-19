include(.project/cmake/Project.cmake)
cmake_minimum_required(VERSION 4.2)
project(Fi VERSION ${fi_version} LANGUAGES CXX)


fi_import(
    Qt6
    COMPONENTS Core Qml
)
fi_import(SQLite3)
fi_import(Catch2)
fi_import(Eigen3)
fi_import(Sophus)
fi_import(ExprTk)
fi_import(OpenCV)
fi_import(VTK)
fi_import(ITK)

fi_project(
    TESTING
)




