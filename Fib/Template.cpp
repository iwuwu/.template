#include "Template.h"

FI_DYNAMIC_TYPE

FI_INITOR(QObject* parent) : QObject(parent)
{
    connect(this, &Template::objectNameChanged, this, &Template::onObjectNameChanged);
    this->setObjectName("Template");
}

FI_METHOD
setObjectName(const QString& objectName)->bool
{
    if (objectName == this->objectName())
    {
        return false;
    }
    QObject::setObjectName(objectName);
    emit objectNameChanged(objectName);
    return true;
}

FI_METHOD
onObjectNameChanged(const QString& objectName)->void
{
    qDebug() << objectName << "in C++";
}