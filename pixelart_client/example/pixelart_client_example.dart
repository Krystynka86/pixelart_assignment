import 'dart:io';
import 'package:pixelart_client/pixelart_client.dart';
import 'package:pixelart_shared/pixelart_shared.dart';
import 'package:uuid/uuid.dart';

void main() async {
  // Initialize a UUID generator
  Uuid uuid = Uuid();

  // Create a new PixelArt object
  PixelArt art = PixelArt(
    id: uuid.v4(),
    name: 'My PixelArt', // You can set a custom name here
    description: 'A pixel art creation',
    width: 64,
    height: 64,
    editors: [],
    pixelMatrix: [[]],
  );

  // Initialize the repository
  final repository = HTTPPixelArtRepository(url: "localhost:8080/pixelart");
  var connected = false;

  // Attempt to connect to the server multiple times with a delay
  for (int i = 0; i < 10; i++) {
    var response = await repository.list();
    if (response.isSuccess) {
      connected = true;
      break;
    } else if (response.status == CRUDStatus.NetworkError) {
      print(
          "NetworkError connecting to the server. Is the server up and running? Start with 'dart_frog dev'");
      await Future.delayed(Duration(seconds: 2));
    }
  }

  if (!connected) {
    print(
        "Unable to connect to the server. Is the server up and running? Start with 'dart_frog dev'");
    print("Exiting. Try again.");
    exit(255);
  }

  // TODO: Use the create/read/list/update/delete/changes methods of the repository to show how they are supposed to be used.

  // Example of using create to create a new pixel art
  final createResult = await repository.create(art);
  if (createResult.isSuccess) {
    final createdArt = createResult.value;
    print('Created PixelArt: ${createdArt!.name}');
  } else {
    print('Failed to create PixelArt: ${createResult.status}');
  }

  // Example of using read to retrieve a pixel art by ID
  final readResult = await repository.read(art.id);
  if (readResult.isSuccess) {
    final retrievedArt = readResult.value;
    print('Retrieved PixelArt: ${retrievedArt!.name}');
  } else {
    print('Failed to retrieve PixelArt: ${readResult.status}');
  }

  // Example of using list to retrieve a list of pixel arts
  final listResult = await repository.list();
  if (listResult.isSuccess) {
    final pixelArts = listResult.value;
    for (final pixelArt in pixelArts!) {
      print('Listed PixelArt: ${pixelArt.name}');
    }
  } else {
    print('Failed to list PixelArts: ${listResult.status}');
  }

  // Example of using update to update an existing pixel art
  final updatedArt = art.copyWith(name: 'Updated PixelArt Name');
  final updateResult = await repository.update(updatedArt.id, updatedArt);
  if (updateResult.isSuccess) {
    print('Updated PixelArt: ${updatedArt.name}');
  } else {
    print('Failed to update PixelArt: ${updateResult.status}');
  }

  // Example of using delete to delete a pixel art by ID
  final deleteResult = await repository.delete(art.id);
  if (deleteResult.isSuccess) {
    print('Deleted PixelArt: ${art.name}');
  } else {
    print('Failed to delete PixelArt: ${deleteResult.status}');
  }

  // Example of using changes to listen for changes in a pixel art
  final changesStream = await repository.changes(art.id);
  changesStream.listen((changedArt) {
    if (changedArt != null) {
      print('Changed PixelArt: ${changedArt.name}');
    } else {
      print('PixelArt deleted or not found.');
    }
  });

  // Exit the application
  print('Exiting application.');
  exit(0);
}
