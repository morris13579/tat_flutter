import 'package:flutter_app/debug/log/Log.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:sprintf/sprintf.dart';

import 'Connector.dart';
import 'NTUTConnector.dart';

enum ISchoolLoginStatus {
  LoginSuccess,
  LoginFail,
  ConnectTimeOutError,
  NetworkError,
  UnknownError
}

class ISchoolConnector {
  static bool _isLogin = false;
  static final String _postLoginISchoolUrl =
      "https://nportal.ntut.edu.tw/ssoIndex.do";
  static final String _iSchoolUrl = "https://ischool.ntut.edu.tw";
  static final String _iSchoolFileUrl =
      "https://ischool.ntut.edu.tw/learning/document/document.php";
  static final String _iSchoolCourseAnnouncementUrl =
      "https://ischool.ntut.edu.tw/learning/announcements/announcements.php";
  static final String _iSchoolNewAnnouncementUrl =
      "https://ischool.ntut.edu.tw/learning/messaging/messagebox.php";
  static final String _iSchoolAnnouncementDetailUrl =
      "https://ischool.ntut.edu.tw/learning/messaging/readmessage.php";
  static final String _iSchoolDownloadUrl =
      "https://ischool.ntut.edu.tw/learning/backends/download.php";

  static Future<ISchoolLoginStatus> login() async {
    String result;
    try {
      Document tagNode;
      List<Element> nodes;
      Map<String, String> data = {
        "apUrl": "https://ischool.ntut.edu.tw/learning/auth/login.php",
        "apOu": "ischool"
      };
      result = await Connector.getDataByGet(_postLoginISchoolUrl, data);
      tagNode = parse(result);
      nodes = tagNode.getElementsByTagName("input");
      data = Map();
      for (Element node in nodes) {
        String name = node.attributes['name'];
        String value = node.attributes['value'];
        data[name] = value;
      }
      Log.d(data.toString());
      result = await Connector.getDataByPost(_iSchoolUrl, data);
      _isLogin = true;
      return ISchoolLoginStatus.LoginSuccess;
    } on Exception catch (e) {
      Log.e(e.toString());
      return ISchoolLoginStatus.LoginFail;
    }
  }

  static Future<bool> getISchoolNewAnnouncement() async {
    int i, j;
    String result;
    String title;
    String postTime;
    String sender;
    String messageId;
    String uid;
    Document tagNode;
    List<Element> nodes, nodesItem;
    try {
      Map<String, String> data = {
        "box": "inbox",
      };
      result = await Connector.getDataByGet(_iSchoolNewAnnouncementUrl, data);
      tagNode = parse(result);
      Log.d( tagNode.outerHtml );
      /*
      nodes = tagNode.getElementsByTagName("tbody"); // 取得兩個取第二個
      nodes = nodes[1].getElementsByTagName("tr");
      for (i = 0; i < nodes.length; i++) {
        nodesItem = nodes[i].getElementsByTagName("td");
        for (j = 0; j < nodesItem.length; j++) {
          switch (j) {
            case 0:
              String href =
                  nodesItem[j].getElementsByTagName("a")[1].attributes["href"];
              uid = nodesItem[j]
                  .getElementsByClassName("im_context")[0]
                  .toString();
              uid = uid.replaceAll(" ", "");
              uid = uid.replaceAll("[", "");
              uid = uid.split("-")[0];
              href = href.replaceAll("amp;", ""); //修正&後出現amp;問題
              messageId = Uri.parse(href).queryParameters["messageId"];
              title = nodesItem[j].getElementsByTagName("a")[1].toString();
              break;
            case 1:
              sender = nodesItem[j].getElementsByTagName("a").toString();
              break;
            case 2:
              postTime = nodesItem[j].toString();
              break;
          }
        }
        Log.d(sprintf("title:%s , postTime:%s , sender:%s , messageId:%s",
            [title, postTime, sender, messageId]));
      }

       */
      return true;
    } on Exception catch (e) {
      Log.e(e.toString());
      return false;
    }
  }

  static bool get isLogin {
    return _isLogin;
  }

  static Future<bool> checkLogin() async {
    Log.d("ISchool CheckLogin");
    try {
      String result =
          await Connector.getDataByGet(_iSchoolCourseAnnouncementUrl);
      if (result.isEmpty) {
        return false;
      } else {
        Log.d("ISchool Is Readly Login");
        return true;
      }
    } on Exception catch (e) {
      throw e;
    }
  }
}