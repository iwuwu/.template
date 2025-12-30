import QtQuick
import QtTest
import Fib

TestCase {
    Template {
        id: obj
        objectName: "Template"
        onObjectNameChanged: {
            console.log(obj.objectName, "in Qml");
        }
        Component.onCompleted: {
            objectName = "Template Again";
        }
    }
}
