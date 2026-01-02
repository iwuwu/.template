#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <catch2/catch_all.hpp>

TEST_CASE("可在Qml中正常编译运行和使用", "[Qml, Build, Run]")
{
    int argc = 0;
    char* argv[]{};
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    engine.addImportPath(app.applicationDirPath() + "/../qml");

    SECTION("正常载入模块")
    {
        engine.loadFromModule("FibTest", "Template");
    }
}