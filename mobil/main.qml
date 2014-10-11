import QtQuick 2.3
import QtQuick.Controls 1.2

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
            navazuji.text = "Obrazovka není v dosahu"
        }
        onServerBusy: {
            navazuji.text = "Obrazovka je momentálně obsazená, čekejte prosím"
        }
        onServerReady: {
            vyber.show()
        }
    }

    Component.onCompleted: {
        dataReader.checkServer()
    }

    menuBar: MenuBar {
        Menu {
            title: qsTr("Game")
            MenuItem {
                text: qsTr("Reset")
                onTriggered: vyber.show()
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
        id: content
        anchors.fill: parent
        color: "transparent"

        Rectangle {
            color: "transparent"
            clip:true
            x: 0
            y: 0
            width: parent.width
            height: parent.height
            id: uvod
            function hide() {
                x = -content.width
            }
            function show() {
                vyber.hide()
                x = 0
            }

            Behavior on x {
                NumberAnimation {
                    duration: 100
                }
            }
            Text {
                id: navazuji
                anchors.fill: parent
                text: "Navazuji spojení s obrazovkou"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                MouseArea {
                    anchors.fill: parent
                    property int clicked: 0
                    onClicked: {
                        clicked++
                        if (clicked == 3) {
                            vyber.show()
                            clicked = 0
                        }
                    }
                }
            }
            Text {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottomMargin: 128
                horizontalAlignment: Text.AlignHCenter
                color: "#444444"
                text: "Hodí se poznamenat,\nže menu se dá prolézt i když je server off\ntím, že člověk 3x poklepe na displej...\nAkorát to nebude nic dělat, OFC"
            }
        }

        Rectangle {
            id: vyber
            color: "transparent"
            x: width
            y: 0
            width: parent.width
            height: parent.height
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
                id: vyberButton
                color: "green"
                height: 64
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 4
                radius: 10

                Text {
                    anchors.centerIn: parent
                    text: "START"
                    font.pointSize: 36
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        dataReader.sendPacket("fight")
                        dataReader.startFight()
                    }
                }
            }
        }
    }
}
