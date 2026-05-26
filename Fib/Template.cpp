#include "Template.h"

FI_DYNAMIC_TYPE

FI_INITOR(QObject* parent) : QObject(parent)
{
    qDebug() << "C++: 构造函数 {";
    connect(this, &Template::objectNameChanged, this, &Template::onObjectNameChanged);
    this->setObjectName("Hello World");
    qDebug() << "C++: }\n";
}

FI_DESTOR
{
    qDebug() << "C++: 析构函数{}";
}

FI_METHOD
setObjectName(const QString& objectName)->bool
{
    qDebug() << qUtf8Printable("C++:     setObjectName(\"" + objectName + "\") {");
    if (objectName == this->objectName())
    {
        return false;
    }
    QObject::setObjectName(objectName);
    emit objectNameChanged(objectName);
    qDebug() << qUtf8Printable("C++:     }");
    return true;
}

FI_METHOD
onObjectNameChanged(const QString& objectName)->void
{
    qDebug() << qUtf8Printable("C++:         onObjectNameChanged(\"" + objectName + "\"){}");
}

FI_METHOD
classBegin()->void
{
    qDebug() << "C++: classBegin() {}";
}
FI_METHOD
componentComplete()->void
{
    qDebug() << "C++: componentComplete() {}\n";
}