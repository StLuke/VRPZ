import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

import QtSensors 5.3

import DataReader 1.0

ApplicationWindow {
    title: "Accelerate Bubble"
    id: mainWindow
    width: 320
    height: 480
    visible: true

    ListModel {
        id: modyModel
        ListElement {
            soubor: "food0.png"
        }
    }

    ListModel {
        id: zvirataModel
        ListElement {
            name: "Bizon"
            soubor: "bison.png"
        }
        ListElement {
            name: "Darth Vader"
            soubor: "vader.png"
        }
        ListElement {
            name: "Slon"
            soubor: "elephant.png"
        }
        ListElement {
            name: "Žirafa"
            soubor: "giraffe.png"
        }
        ListElement {
            name: "Koza"
            soubor: "goat.png"
        }
        ListElement {
            name: "Lev"
            soubor: "lion.png"
        }
        ListElement {
            name: "Opice"
            soubor: "monkey.png"
        }
        ListElement {
            name: "Ovce"
            soubor: "sheep.png"
        }
    }


    ListModel {
        id: zbraneModel
        ListElement {
            soubor: "bison_weapon.png"
        }
        ListElement {
            soubor: "vader_weapon.png"
        }
        ListElement {
            soubor: "elephant_weapon.png"
        }
        ListElement {
            soubor: "giraffe_weapon.png"
        }
        ListElement {
            soubor: "goat_weapon.png"
        }
        ListElement {
            soubor: "lion_weapon.png"
        }
        ListElement {
            soubor: "monkey_weapon.png"
        }
        ListElement {
            soubor: "sheep_weapon.png"
        }
    }

    DataReader {
        id: dataReader
        onServerMissing: {
            vyberButton.ready = false
        }
        onServerReady: {
            vyberButton.ready = true
        }
    }

    menuBar: MenuBar {
        Menu {
            title: qsTr("Game")
            MenuItem {
                text: qsTr("Špatná IP obrazovky")
                onTriggered: nastaveniIP.visible = true
            }

            MenuItem {
                text: qsTr("Exit")
                onTriggered: Qt.quit();
            }
        }
    }

    Image {
        anchors.fill: parent
        source: "mainbg.jpg"
        fillMode: Image.PreserveAspectCrop
        Rectangle {
            anchors.fill: parent
            color: "white"
            opacity: 0.5
        }
    }

    Rectangle {
        id: nastaveniIP
        anchors.fill: parent
        visible: false
        z: 2
        onVisibleChanged: ipField.text = ""
        Text {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: parent.width /32
            id: ipText
            text: "IP nebo hostname:"
            font.pixelSize: parent.width / 16
        }

        TextField {
            id: ipField
            anchors.margins: parent.width / 32
            height: parent.width / 8
            anchors.top: ipText.bottom
            anchors.left: parent.left
            anchors.right: parent.right
        }
        Button {
            anchors.margins: ipField.anchors.margins
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: ipField.width / 3
            height: ipField.height
            text: "Storno"
            onClicked: parent.visible = false
        }
        Button {
            anchors.margins: ipField.anchors.margins
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            width: ipField.width / 3
            height: ipField.height
            text: "OK"
            onClicked: {
                dataReader.setHost(ipField.text)
                parent.visible = false
            }
        }
    }

    Rectangle {
        id: vyber
        color: "transparent"
        anchors.fill: parent
        Behavior on x {
            NumberAnimation {
                duration: 100
            }
        }
        function hide() {
            x = -content.width
        }
        function show() {
            uvod.hide()
            x = 0
        }

        Text {
            id: vyberText
            height: 0
        }

        ListView {
            id: seznamModu
            anchors.top: vyberText.bottom
            anchors.left:parent.left
            anchors.bottom: vyberButton.top
            anchors.margins: 4
            width: parent.width / 3
            clip: true
            spacing: 8
            model: modyModel
            delegate: Rectangle {
                color: "transparent"
                height: width
                width: parent.width
                Image {
                    id: nabidkaObrazek
                    anchors.fill: parent
                    source:soubor
                    width: height
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                    }
                }
            }
        }


        ListView {
            id: seznamZvirat
            spacing: 10
            model: zvirataModel
            clip:true
            anchors.top: vyberText.bottom
            anchors.bottom: vyberButton.top
            anchors.left: seznamModu.right
            anchors.margins: 4
            width: parent.width / 3

            delegate: Rectangle {
                Image {
                    anchors.fill: parent
                    anchors.margins: 4
                    id: zvireKsicht
                    source: soubor
                }

                color: "transparent"
                width: parent.width
                height: width
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        dataReader.sendPacket("ksicht:"+soubor)
                    }
                }
            }
        }



        ListView {
            id: seznamZbrani
            spacing: 10
            model: zbraneModel
            clip:true
            anchors.top: vyberText.bottom
            anchors.bottom: vyberButton.top
            anchors.left: seznamZvirat.right
            anchors.right: parent.right
            anchors.margins: 4

            delegate: Rectangle {
                Image {
                    anchors.fill: parent
                    anchors.margins: 4
                    id: zbranObrazek
                    source: soubor
                    scale: 2
                    transform: Translate { x: -(parent.width/2) }
                }

                color: "transparent"
                width: parent.width
                height: width
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        dataReader.sendPacket("zbran:"+soubor)
                    }
                }
            }
        }

        Rectangle {
            id: shadow
            anchors.fill: parent
            color: "#444444"
            opacity: vyberButton.ready ? 0 : 0.8
        }

        Rectangle {
            property bool ready: false

            id: vyberButton
            color: ready ? "green" : "red"
            height: parent.height / 10
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 4
            radius: 10
            z: 2

            Text {
                id: vyberButtonText
                anchors.centerIn: parent
                text: parent.ready ? "START" : "Navazuji spojení s obrazovkou"
                font.pointSize: parent.ready ? (parent.width * 0.1) : (parent.width * 0.05)
            }
            MouseArea {
                anchors.fill: parent
                property int cnt: 0
                onClicked: {
                    if (parent.color != "red") {
                        dataReader.sendPacket("fight")
                        dataReader.startFight()
                    }
                    else {
                        cnt++
                        if (cnt == 3) {
                            cnt = 0
                        }
                    }
                }
            }
        }
    }
}
