#pragma once

#include <QObject>
#include <QString>
#include <QtQml>

#include "./FiModule.h"

FI_CLASS
Contorller : public QThread
{
    Q_OBJECT
    Q_PROPERTY(QString objectName READ objectName WRITE setObjectName NOTIFY objectNameChanged)
    QML_ELEMENT

public:
    Contorller(QObject* parent = nullptr);
    ~Contorller() noexcept;

signals:
    void objectNameChanged(const QString& objectName);

public slots:
    bool setObjectName(const QString& objectName);
    void onObjectNameChanged(const QString& objectName);

private:
}
FI_END