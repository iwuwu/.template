#pragma once

#include <QObject>
#include <QProperty>
#include <QString>
#include <QtQml>

#include "./FiModule.h"

FI_CLASS
Template : public QObject, public QQmlParserStatus
{
    Q_OBJECT
    Q_PROPERTY(QString objectName READ objectName WRITE setObjectName NOTIFY objectNameChanged)

    Q_INTERFACES(QQmlParserStatus)
    QML_ELEMENT

public:
    Template(QObject* parent = nullptr);
    ~Template() noexcept;

signals:
    void objectNameChanged(const QString& objectName);

public slots:
    bool setObjectName(const QString& objectName);
    void onObjectNameChanged(const QString& objectName);

protected:
    void classBegin() override;
    void componentComplete() override;

private:
    QString m_message;
}
FI_END
