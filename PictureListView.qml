import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0
import QtQuick.XmlListModel 2.0

Item {
    id: mainScreen

    XmlListModel {
        id: feedModel

        //     source: "http://api.flickr.com/services/feeds/photos_public.gne?format=rss2"
        source: "http://api.flickr.com/services/feeds/photos_public.gne?format=rss2&tags=" + escape(input.text)
        query: "/rss/channel/item"  // flickr
        namespaceDeclarations:  "declare namespace media=\"http://search.yahoo.com/mrss/\";"

        // Flickr
        XmlRole { name: "title"; query: "title/string()" }
        XmlRole { name: "imagePath"; query: "media:thumbnail/@url/string()" }
        XmlRole { name: "photoAuthor"; query: "author/string()" }
        XmlRole { name: "photoDate"; query: "pubDate/string()" }

        XmlRole { name: "url"; query: "media:content/@url/string()" }
        XmlRole { name: "description"; query: "description/string()" }
        XmlRole { name: "tags"; query: "media:category/string()" }
        XmlRole { name: "photoWidth"; query: "media:content/@width/string()" }
        XmlRole { name: "photoHeight"; query: "media:content/@height/string()" }
        XmlRole { name: "photoType"; query: "media:content/@type/string()" }
    }

    ListModel {
        id: sampleListModel

        ListElement {
            imagePath: "images/sample.jpg"
            title: "First picture"
        }
        ListElement {
            imagePath: "images/sample.jpg"
            title: "Second picture"
        }
        ListElement {
            imagePath: "images/sample.jpg"
            title: "Third picture"
        }
    }

    Component {
        id: listDelegate
        BorderImage {
            source: "images/list.png"
            border { top:4; left:4; right:100; bottom: 4 }
            anchors.right: parent.right
            // width: mainScreen.width
            width: ListView.view.width
            height: 180

            property int fontSize: 25

            Rectangle {
                id: imageId
                x: 6; y: 4; width: parent.height - 10; height:width; color: "white"; smooth: true
                anchors.verticalCenter: parent.verticalCenter

                SpinnerImage {
                    source: imagePath; x: 0; y: 0
                    height:parent.height
                    width:parent.width
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Text {
                x: imageId.width + 20
                y: 15
                width: mainScreen.width - x - 40
                text: title; color: "white"
                font { pixelSize: fontSize; bold: true }
                elide: Text.ElideRight; style: Text.Raised; styleColor: "black"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    viewscreen.source = imagePath.replace("_s", "_m")
                    mainScreen.state = "view"
                }
            }
        }
    }

    states: [
        State {
            name: "view"
            PropertyChanges {
                target: viewcontainer
                x:-mainScreen.width
            }
            PropertyChanges {
                target: backbutton
                opacity:1
            }
            PropertyChanges {
                target: inputcontainer
                opacity:0
            }
        }
    ]

    transitions: [
        Transition {
            NumberAnimation { target: viewcontainer; property: "x"; duration: 500
                easing.type:Easing.OutSine}
            NumberAnimation { target: inputcontainer; property: "opacity"; duration: 200}
            NumberAnimation { target: backbutton; property: "opacity"; duration: 200}
        }
    ]

    Row {
        id:viewcontainer

        UbuntuListView {
            id: listView
            width: mainScreen.width
            height:mainScreen.height - toolbar.height

            model: feedModel
            delegate: listDelegate

            // let refresh control know when the refresh gets completed
            PullToRefresh {
                refreshing: listView.model.status === XmlListModel.Loading
                onRefresh: listView.model.reload()
            }

            Scrollbar {
                flickableItem: listView
            }
        }

        DetailedImage {
            id:viewscreen
            clip:true
            width:mainScreen.width
            height:mainScreen.height - toolbar.height
            smooth:true
            fillMode:Image.PreserveAspectFit

            onSwipeRight: {
                onClicked: mainScreen.state=""
            }
        }
    }

    BorderImage {
        id:toolbar

        anchors.bottom:parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        width: parent.width
        height: units.gu(6)

        source: "images/toolbar.png"
        border.left: 4; border.top: 4
        border.right: 4; border.bottom: 4

        Row {
            id:inputcontainer
            anchors.centerIn:toolbar
            anchors.verticalCenterOffset:6
            spacing:12
            Text {
                id:label
                font.pixelSize:30
                anchors.verticalCenter:parent.verticalCenter;
                text: i18n.tr("Search:")
                font.bold:true
                style:Text.Raised
                styleColor:"#fff"
                color:"#444"
            }

            TextField {
                id:input
                placeholderText: "Please input a text to search:"
                width:220
                text:"Beijing"
            }
        }

        Image {
            id: backbutton
            opacity:0
            source: "images/back.png"
            anchors.verticalCenter:parent.verticalCenter
            anchors.verticalCenterOffset:0
            anchors.left:parent.left
            anchors.leftMargin:8

            MouseArea{
                anchors.fill:parent
                onClicked: mainScreen.state=""
                scale:4
            }
        }
    }
}
