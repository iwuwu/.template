#pragma once

#include <QObject>
#include <QString>
#include <QtQml>

#include "./FiModule.h"

FI_CLASS
Template : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString objectName READ objectName WRITE setObjectName NOTIFY objectNameChanged)
    QML_ELEMENT

public:
    Template(QObject* parent = nullptr);
    ~Template() noexcept;

signals:
    void objectNameChanged(const QString& objectName);

public slots:
    bool setObjectName(const QString& objectName);
    void onObjectNameChanged(const QString& objectName);
}
FI_END
