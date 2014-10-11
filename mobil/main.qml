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
            url: "http://icons.iconarchive.com/icons/icons8/windows-8/512/Military-Sword-icon.png"
            name: "Sám proti přírodě"
        }
        ListElement {
            url: "https://cdn3.iconfinder.com/data/icons/ahasoft-war/512/guard-512.png"
            name: "Zápas"
        }
    }

    ListModel {
        id: zvirataModel
        ListElement {
            name: "Bizon"
            soubor: "bison.png"
            url: "http://img2.wikia.nocookie.net/__cb20120812082359/adventuretimewithfinnandjake/images/0/06/Pig_trans.png"
        }
        ListElement {
            name: "Darth Vader"
            soubor: "vader.png"
            url: "http://i.ytimg.com/vi/kvSrg8qT0hY/hqdefault.jpg"
        }
        ListElement {
            name: "Kráva"
            soubor: "cow.png"
            url: "http://i.ytimg.com/vi/kvSrg8qT0hY/hqdefault.jpg"
        }
        ListElement {
            name: "Slon"
            soubor: "elephant.png"
            url: "http://i.ytimg.com/vi/kvSrg8qT0hY/hqdefault.jpg"
        }
        ListElement {
            name: "Žirafa"
            soubor: "giraffe.png"
            url: "http://i.ytimg.com/vi/kvSrg8qT0hY/hqdefault.jpg"
        }
        ListElement {
            name: "Koza"
            soubor: "goat.png"
            url: "http://i.ytimg.com/vi/kvSrg8qT0hY/hqdefault.jpg"
        }
        ListElement {
            name: "Lev"
            soubor: "lion.png"
            url: "http://i.ytimg.com/vi/kvSrg8qT0hY/hqdefault.jpg"
        }
        ListElement {
            name: "Opice"
            soubor: "monkey.png"
            url: "http://i.ytimg.com/vi/kvSrg8qT0hY/hqdefault.jpg"
        }
        ListElement {
            name: "Ovce"
            soubor: "sheep.png"
            url: "http://i.ytimg.com/vi/kvSrg8qT0hY/hqdefault.jpg"
        }
    }


    ListModel {
        id: zbraneModel
        ListElement {
            name: "Světelný meč"
            soubor: "lightsaber.png"
            url: "http://a.tgcdn.net/images/products/frontsquare/b72c_star_wars_lightsaber_single.jpg"
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
                onTriggered: uvod.show()
            }

            MenuItem {
                text: qsTr("Exit")
                onTriggered: Qt.quit();
            }
        }
    }

    Image {
        anchors.fill: parent
        source: "http://picturesforcoloring.com/wp-content/uploads/2012/05/jungle-wallpaper.jpg"
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
                mody.hide()
                fight.hide()
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
                        if (clicked == 5) {
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
                text: "Hodí se poznamenat,\nže menu se dá prolézt i když je server off\ntím, že člověk 5x poklepe na displej...\nAkorát to nebude nic dělat, OFC"
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
                text: "OFC"
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
                        source:url
                        width: height
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            avatary.show()
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
                        source: url
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
                        source: url
                    }

                    color: "transparent"
                    width: parent.width
                    height: width
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            dataReader.sendPacket("zbran:"+soubor)
                            fight.show()
                            dataReader.sendPacket("fight")
                            dataReader.startFight()
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
            }
        }

        Rectangle {
            color: "transparent"
            clip: true
            id: fight
            x: parent.width
            y: 0
            width: parent.width
            height: parent.height
            function hide() {
                x = -content.width
            }
            function show() {
                uvod.hide()
                vyber.hide()
                x = 0
            }
            Behavior on x {
                NumberAnimation {
                    duration: 200
                }
            }

            Text {
                anchors.left: parent.left
                anchors.right: parent.right
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 32
                text: "FIIIGHT!"
            }
        }
    }
}
