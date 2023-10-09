import 'dart:convert';
import 'package:pixelart_shared/pixelart_shared.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

class HTTPPixelArtRepository extends AbstractPixelArtRepository {
  final String url;
  final String _HTTPurl;
  final String _WSurl;

  const HTTPPixelArtRepository({required this.url})
      : _HTTPurl = "http://" + url,
        _WSurl = "ws://" + url;

  @override
  Future<CRUDResult<PixelArt>> create(PixelArt item) async {
    try {
      // 16. Post item as serialized string to http url and await response
      final response = await http.post(
        Uri.parse(_HTTPurl),
        body: item.serialize(), // Serialize the item to JSON
        headers: {
          'Content-Type': 'application/json'
        }, // Set appropriate headers
      );

      if (response.statusCode == 201) {
        return CRUDResult.success(PixelArt.deserialize(response.body));
      } else {
        return CRUDResult.failure(response.statusCode.toCRUDStatus);
      }
    } catch (e) {
      return CRUDResult.failure(CRUDStatus.NetworkError, e);
    }
  }

  @override
  Future<CRUDResult<PixelArt>> read(String id) async {
    try {
      //17. check if response was successful and return success/failure result by deserializing the body or providing the failed crudstatus
      final response = await http.get(Uri.parse('$_HTTPurl/$id'));

      if (response.statusCode == 200) {
        return CRUDResult.success(PixelArt.deserialize(response.body));
      } else {
        return CRUDResult.failure(response.statusCode.toCRUDStatus);
      }
    } catch (e) {
      return CRUDResult.failure(CRUDStatus.NetworkError, e);
    }
  }

  @override
  Future<CRUDResult<PixelArt>> update(String id, PixelArt item) async {
    try {
      //18. use HTTP PUT with item serialized as body to HTTPURL/[id]. Make sure to error handle and return proper crudresults.
      final response = await http.put(
        Uri.parse('$_HTTPurl/$id'),
        body: item.serialize(), // Serialize the item to JSON
        headers: {
          'Content-Type': 'application/json'
        }, // Set appropriate headers
      );

      if (response.statusCode == 200) {
        return CRUDResult.success(PixelArt.deserialize(response.body));
      } else {
        return CRUDResult.failure(response.statusCode.toCRUDStatus);
      }
    } catch (e) {
      return CRUDResult.failure(CRUDStatus.NetworkError, e);
    }
  }

  @override
  Future<CRUDResult<void>> delete(String id) async {
    try {
      //19. use HTTP DELETE to HTTPURL/[id]. Make sure to error handle and return proper crudresults.
      final response = await http.delete(Uri.parse('$_HTTPurl/$id'));

      if (response.statusCode == 204) {
        return CRUDResult.success();
      } else {
        return CRUDResult.failure(response.statusCode.toCRUDStatus);
      }
    } catch (e) {
      return CRUDResult.failure(CRUDStatus.NetworkError, e);
    }
  }

  @override
  Future<CRUDResult<List<PixelArt>>> list() async {
    try {
      final response = await http.get(Uri.parse(_HTTPurl));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        List<PixelArt> items =
            body.map((e) => PixelArt.deserialize(e as String)).toList();
        return CRUDResult.success(items);
      } else {
        return CRUDResult.failure(response.statusCode.toCRUDStatus);
      }
    } catch (e) {
      return CRUDResult.failure(CRUDStatus.NetworkError, e);
    }
  }

  @override
  Future<Stream<PixelArt?>> changes(String id) async {
    final uri = Uri.parse('$_WSurl/$id/stream');
    final channel = WebSocketChannel.connect(uri);
    return channel.stream.map((event) {
      if (event.runtimeType == String) {
        event = event as String;
        return event.isNotEmpty ? PixelArt.deserialize(event) : null;
      } else {
        return null;
      }
    });
  }
}
