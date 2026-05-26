import QtQuick
import QtTest
import Fib

TestCase {
    Template {
        id: obj
        objectName: "Template"
        onObjectNameChanged: {
            console.log("Object Name Change To " + obj.objectName + " In Qml");
        }
        Component.onCompleted: {
            console.log(obj.objectName + " Constructed In Qml");
            obj.objectName = "Hello World Again";
        }
        Component.onDestruction: {
            console.log(obj.objectName + " Destructed In Qml");
        }
    }
}
