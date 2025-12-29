import QtQuick
import QtQuick.Controls
import Fib

ApplicationWindow {
    width: 800
    height: 600
    visible: true
    Button {
        text: obj.objectName
        onClicked: {
            obj.objectName = "Nice";
        }
    }
    Template {
        id: obj
        onObjectNameChanged: {
            console.log(obj.objectName, "in Qml");
        }
    }
}
