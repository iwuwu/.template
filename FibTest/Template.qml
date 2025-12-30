import QtQuick
import QtTest
import Fib

TestCase {
    Template {
        id: template
        objectName: "Template"
        onObjectNameChanged: {
            console.log(template.objectName, "in Qml");
        }
    }
}
