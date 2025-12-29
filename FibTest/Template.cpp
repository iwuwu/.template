#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <catch2/catch_all.hpp>

TEST_CASE("可在Qml中正常编译运行和使用", "[Qml, Build, Run]")
{
    int argc = 0;
    char* argv[]{};
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    qDebug() << engine.importPathList();
    engine.loadFromModule("FibTest", "Template");

    SECTION("进入和正常退出消息循环") {}
}