import QtQuick
import QtTest
import Fib

TestCase {
    Template {
        id: obj
        objectName: "Template"
        onObjectNameChanged: {
            console.log("        onObjectNameChanged(\"" + obj.objectName + "\"){}");
        }
        Component.onCompleted: {
            console.log("Component.onCompleted() {");
            console.log("    objectName = \"" + obj.objectName + " Hello World Again\"");
            obj.objectName = obj.objectName + " Hello World Again";
            console.log("}\n");
        }
        Component.onDestruction: {
            console.log("Component.onDestruction() {}");
        }
    }
}
