import 'dart:io';
import 'package:path/path.dart' as p;

const int a = 13;
const int b = 12;
const int m = 256;

// Функция для шифрования аффинным шифром
int encryptByte(int byte) {
  return (a * byte + b) % m;
}

// Функция для нахождения обратного числа по модулю (а^-1)
int modInverse(int a, int m) {
  a = a % m;
  for (int x = 1; x < m; x++) {
    if ((a * x) % m == 1) return x;
  }
  throw Exception('Нет обратного числа для a = $a');
}

// Функция для расшифровки аффинным шифром
int decryptByte(int byte) {
  int aInverse = modInverse(a, m);
  return (aInverse * (byte - b)) % m;
}

// Функция для обработки файла (шифрование/расшифровка)
void processFile(String inputFile, String outputFile, bool isEncrypt) async {
  try {
    // Открытие файлов с явной обработкой путей
    var input = File(inputFile);
    var output = File(outputFile);

    // Чтение содержимого
    var inputBytes = await input.readAsBytes();
    var outputBytes = <int>[];

    for (var byte in inputBytes) {
      int processedByte = isEncrypt ? encryptByte(byte) : decryptByte(byte);
      outputBytes.add(processedByte);
    }

    // Запись содержимого в файл
    await output.writeAsBytes(outputBytes);
    print('Файл успешно сохранён: $outputFile');
  } catch (e) {
    print('Ошибка при обработке файла: $e');
  }
}

// Функция для показа файлов в директории
void showFilesInDirectory(String directoryPath) {
  try {
    var dir = Directory(directoryPath);
    var files = dir.listSync().where((entity) => entity is File);

    if (files.isEmpty) {
      print('Нет файлов в директории.');
      return;
    }

    int index = 1;
    for (var file in files) {
      print('$index. ${p.basename(file.path)}');
      index++;
    }
  } catch (e) {
    print('Ошибка при выводе файлов в директории: $e');
  }
}

// Ввод пути к директории с проверкой на существование и нормализацией путей
String getDirectoryPath() {
  while (true) {
    print('Введите путь к директории:');
    String? path = stdin.readLineSync();

    if (path != null) {
      // Нормализуем путь
      String normalizedPath = p.normalize(path);

      try {
        if (Directory(normalizedPath).existsSync()) {
          return normalizedPath;
        } else {
          print('Директория не найдена. Попробуйте снова.');
        }
      } catch (e) {
        print('Ошибка при проверке директории: $e');
      }
    }
  }
}

// Ввод номера файла с проверкой
String chooseFile(String directoryPath) {
  var files = Directory(directoryPath)
      .listSync()
      .where((entity) => entity is File)
      .toList();

  if (files.isEmpty) {
    print('Нет доступных файлов для выбора.');
    exit(1);
  }

  while (true) {
    print('Введите номер файла для обработки:');
    String? fileChoice = stdin.readLineSync();
    try {
      int fileIndex = int.parse(fileChoice!) - 1;
      if (fileIndex >= 0 && fileIndex < files.length) {
        return files[fileIndex].path;
      } else {
        print('Неверный номер файла. Попробуйте снова.');
      }
    } catch (e) {
      print('Некорректный ввод. Введите номер файла.');
    }
  }
}

// Главное меню программы с проверкой
void mainMenu() {
  while (true) {
    print('Выберите операцию:');
    print('1. Зашифровать файл');
    print('2. Расшифровать файл');
    String? choice = stdin.readLineSync();

    if (choice == '1' || choice == '2') {
      bool isEncrypt = choice == '1';

      print('Выберите директорию:');
      print('1. Использовать текущую директорию');
      print('2. Ввести путь к другой директории');
      String? dirChoice = stdin.readLineSync();

      String directoryPath;
      if (dirChoice == '1') {
        directoryPath = Directory.current.path;
      } else if (dirChoice == '2') {
        directoryPath = getDirectoryPath();
      } else {
        print('Неверный выбор. Попробуйте снова.');
        continue;
      }

      print('Файлы в директории $directoryPath:');
      showFilesInDirectory(directoryPath);

      String inputFile = chooseFile(directoryPath);

      print('Введите имя для сохранения результата:');
      String? outputFileName = stdin.readLineSync();
      if (outputFileName == null || outputFileName.isEmpty) {
        print('Имя файла не может быть пустым.');
        continue;
      }
      String outputFile = '$directoryPath/$outputFileName';

      processFile(inputFile, outputFile, isEncrypt);
      break;
    } else {
      print('Неверный выбор операции. Попробуйте снова.');
    }
  }
}

// Точка входа в программу
void main() {
  mainMenu();
}
