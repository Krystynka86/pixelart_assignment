import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:pixelart_server/src/helpers.dart';
import 'package:pixelart_server/src/hive_repository.dart';
import 'package:pixelart_shared/pixelart_shared.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => get(context),
    HttpMethod.post => post(context),
    _ => Future.value(
        Response(statusCode: CRUDStatus.NotFound.toHTTPStatusCode),
      )
  };
}

Future<Response> post(RequestContext context) async {
  final repository = await context.read<Future<HivePixelArtRepository>>();

  final request = context.request;

  // 10. Deserialize the request body to retrieve a pixelArt for creation.
  try {
    // Deserialize the request body to retrieve a PixelArt for creation
    final requestBody = await request.body();
    final pixelArt = PixelArt.deserialize(requestBody);

    final result = await repository.create(pixelArt);

    if (result.isSuccess) {
      return result.toHTTPSuccess(
        body: pixelArt.serialize(),
      );
    } else {
      return result.toHTTPError();
    }
  } catch (e) {
    return Response(
      statusCode: 500,
      body: 'Invalid request body: $e',
    );
  }
}

Future<Response> get(RequestContext context) async {
  final repository = await context.read<Future<HivePixelArtRepository>>();

  final result = await repository.list();

  if (result.isSuccess) {
    final pixelarts = result.value!.map((e) => e.serialize()).toList();
    return result.toHTTPSuccess(
      body: jsonEncode(pixelarts),
    );
  } else {
    return result.toHTTPError();
  }
}
