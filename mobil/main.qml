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

    DataReader {
        id: dataReader
        onServerMissing: {
            navazuji.text = "Obrazovka není v dosahu"
        }
        onServerBusy: {
            navazuji.text = "Obrazovka je momentálně obsazená, čekejte prosím"
        }
        onServerReady: {
            mody.show()
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
                avatary.hide()
                zbrane.hide()
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
                            mody.show()
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
            color: "transparent"
            clip:true
            x: width
            y: 0
            width: parent.width
            height: parent.width
            id: mody
            function hide() {
                x = -content.width
            }
            function show() {
                uvod.hide()
                avatary.hide()
                zbrane.hide()
                fight.hide()
                x = 0
            }

            Behavior on x {
                NumberAnimation {
                    duration: 100
                }
            }

            Text {
                id: titulek
                text: "Vyber si herní mód"
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 24
                anchors.left: parent.left
                anchors.right: parent.right
            }

            ListView {
                anchors.top: titulek.bottom
                anchors.right: parent.right
                anchors.left:parent.left
                anchors.bottom: parent.bottom
                clip: true
                spacing: 8
                model: ListModel {
                    ListElement {
                        url: "http://icons.iconarchive.com/icons/icons8/windows-8/512/Military-Sword-icon.png"
                        name: "Sám proti přírodě"
                    }
                    ListElement {
                        url: "https://cdn3.iconfinder.com/data/icons/ahasoft-war/512/guard-512.png"
                        name: "Zápas"
                    }
                }
                delegate: Rectangle {
                    color: "transparent"
                    height: 96
                    width: parent.width
                    Image {
                        id: nabidkaObrazek
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        source:url
                        width: height
                    }
                    Text {
                        anchors.left: nabidkaObrazek.right
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.bottom:parent.bottom
                        text: name
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: 24
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            avatary.show()
                        }
                    }
                }
            }
        }

        Rectangle {
            color: "transparent"
            clip: true
            id: avatary
            x: parent.width
            y: 0
            width: parent.width
            height: parent.height
            function hide() {
                x = -content.width
            }
            function show() {
                uvod.hide()
                mody.hide()
                zbrane.hide()
                fight.hide()
                x = 0
            }
            Behavior on x {
                NumberAnimation {
                    id: anim
                    duration: 200
                }
            }

            Text {
                anchors.left: parent.left
                anchors.right: parent.right
                horizontalAlignment: Text.AlignHCenter
                id: avatarText
                font.pointSize: 32
                text: "Vyber si avatara"
            }

            ListView {
                id: seznamZvirat
                spacing: 10
                model: zvirata
                clip:true
                anchors.top: avatarText.bottom
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right

                delegate: Rectangle {
                    Image {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.margins: 4
                        id: zvireKsicht
                        height: parent.height
                        width: height
                        source: url
                    }

                    Text {
                        anchors.left: zvireKsicht.right
                        anchors.right: parent.right
                        anchors.leftMargin: 8
                        height: parent.height

                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: 28
                        text: name
                    }

                    color: "transparent"
                    width: parent.width
                    height: 92
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            dataReader.sendPacket("ksicht:"+soubor)
                            zbrane.show()
                        }
                    }
                }
            }

            ListModel {
                id: zvirata
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
        }

        Rectangle {
            color: "transparent"
            clip: true
            id: zbrane
            x: parent.width
            y: 0
            width: parent.width
            height: parent.height
            function hide() {
                x = -content.width
            }
            function show() {
                uvod.hide()
                mody.hide()
                avatary.hide()
                fight.hide()
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
                id: zbraneText
                font.pointSize: 32
                text: "Vyber si zbraň"
            }


            ListView {
                id: seznamZbrani
                spacing: 10
                model: zbraneModel
                clip:true
                anchors.top: zbraneText.bottom
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right

                delegate: Rectangle {
                    Image {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.margins: 4
                        id: zbranObrazek
                        height: parent.height
                        width: height
                        source: url
                    }

                    Text {
                        anchors.left: zbranObrazek.right
                        anchors.right: parent.right
                        anchors.leftMargin: 8
                        height: parent.height

                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: 28
                        text: name
                    }

                    color: "transparent"
                    width: parent.width
                    height: 92
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

            ListModel {
                id: zbraneModel
                ListElement {
                    name: "Světelný meč"
                    soubor: "lightsaber.png"
                    url: "http://a.tgcdn.net/images/products/frontsquare/b72c_star_wars_lightsaber_single.jpg"
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
                mody.hide()
                avatary.hide()
                zbrane.hide()
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
