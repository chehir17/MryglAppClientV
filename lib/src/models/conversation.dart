import 'user.dart';

class Conversation {
  String? id;
  String? name; // conversation name for example chat with market name
  String? lastMessage;
  int? lastMessageTime;

  // Ids of users that read the chat message
  List<String> readByUsers = [];

  // Ids of users in this conversation
  List<String> visibleToUsers = [];

  // users in the conversation
  List<User> users = [];

  Conversation(this.users, {this.id, this.name = ''}) {
    visibleToUsers = users
        .map((user) => user.id ?? '')
        .where((id) => id.isNotEmpty)
        .toList();
    readByUsers = [];
  }

  Conversation.fromJSON(Map<String, dynamic>? jsonMap) {
    try {
      id = jsonMap?['id']?.toString();
      name = jsonMap?['name']?.toString() ?? '';

      readByUsers = jsonMap?['read_by_users'] != null
          ? List<String>.from((jsonMap!['read_by_users'] as List)
              .map((e) => e?.toString() ?? ''))
          : <String>[];

      visibleToUsers = jsonMap?['visible_to_users'] != null
          ? List<String>.from((jsonMap!['visible_to_users'] as List)
              .map((e) => e?.toString() ?? ''))
          : <String>[];

      lastMessage = jsonMap?['message']?.toString() ?? '';
      lastMessageTime = jsonMap?['time'] is int ? jsonMap!['time'] : 0;

      users = jsonMap?['users'] != null
          ? (jsonMap!['users'] as List).map((element) {
              element['media'] = [
                {'thumb': element['thumb']}
              ];
              return User.fromJSON(element);
            }).toList()
          : <User>[];
    } catch (e) {
      id = '';
      name = '';
      readByUsers = [];
      visibleToUsers = [];
      users = [];
      lastMessage = '';
      lastMessageTime = 0;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "users": users.map((element) => element.toRestrictMap()).toSet().toList(),
      "visible_to_users":
          users.map((element) => element.id ?? '').toSet().toList(),
      "read_by_users": readByUsers,
      "message": lastMessage,
      "time": lastMessageTime,
    };
  }

  Map<String, dynamic> toUpdatedMap() {
    return {
      "message": lastMessage,
      "time": lastMessageTime,
      "read_by_users": readByUsers,
    };
  }
}
