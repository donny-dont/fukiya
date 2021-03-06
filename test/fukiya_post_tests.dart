library fukiyPostTests;
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:crypto/crypto.dart';
import 'package:unittest/unittest.dart';

class FukiyaPostTests {
  static HttpClient client = new HttpClient();

  static Future<bool> runTests() {
    Completer completer = new Completer();
    group('[POST TESTS]', () {
      test('Simple POST Request', () {
        String finalString = '';
        var atest = expectAsync0(() {
          client.post('127.0.0.1', 3333, '/').then((HttpClientRequest request) {
            request.headers.contentType = new ContentType('application', 'json', charset: 'utf-8');
            request.contentLength = '{ "username": "daegalus", "password": "somePass" }'.length;
            request.write('{ "username": "daegalus", "password": "somePass" }');
            return request.close();

          }).then((HttpClientResponse response) {
            response.transform(new Utf8Decoder())
            .transform(new LineSplitter())
            .listen((String result) {
              finalString += result;
            },
            onDone: () {
              expect(finalString, equals('POST OK daegalus - somePass'));
            });
          });
        });
        atest();
      });

      test('Simple POST Request with Post Data URLEncoded', () {
        String finalString = '';
        var atest = expectAsync0(() {
          client.post('127.0.0.1', 3333, '/').then((HttpClientRequest request) {
            request.headers.contentType = new ContentType('application', 'x-www-form-urlencoded', charset: 'utf-8');
            request.contentLength = 'username=daegalus&password=somePass'.length;
            request.write('username=daegalus&password=somePass');
            return request.close();

          }).then((HttpClientResponse response) {
            response.transform(new Utf8Decoder())
            .transform(new LineSplitter())
            .listen((String result) {
              finalString += result;
            },
            onDone: () {
              expect(finalString, equals('POST OK daegalus - somePass'));
            });
          });
        });
        atest();
      });

      test('Complex POST Request with Dynamic Path', () {
        String finalString = '';

        var atest = expectAsync0(() {
          client.post('127.0.0.1', 3333, '/3727328732').then((HttpClientRequest request) {
            request.headers.contentType = new ContentType('application', 'json', charset: 'utf-8');
            request.contentLength = '{ "username": "daegalus", "password": "somePass" }'.length;
            request.write('{ "username": "daegalus", "password": "somePass" }');
            return request.close();

          }).then((HttpClientResponse response) {
            response.transform(new Utf8Decoder())
            .transform(new LineSplitter())
            .listen((String result) {
              finalString += result;
            },
            onDone: () {
              expect(finalString, equals('Dynamic POST OK 3727328732 - daegalus'));
              completer.complete(true);
            });
          });
        });
        atest();
      });
    });

    test('[POST] Simple POST Request with Post Base64 Data MultiPart', () {
      String finalString = '';
      var atest = expectAsync0(() {
        client.post('127.0.0.1', 3333, '/postData').then((HttpClientRequest request) {
          request.headers.contentType = new ContentType('multipart', 'form-data', charset: 'utf-8', parameters: {'boundary':'AaB03x'});

          String postData =  '--aab03x\r\n'
          'Content-Disposition: form-data; name="submit-name"\r\n'
          '\r\n'
          'Larry\r\n'
          '--aab03x\r\n'
          'Content-Disposition: form-data; name="file"; filename="image.jpg"\r\n'
          'Content-Type: image/jpeg\r\n'
          'Content-Transfer-Encoding: base64\r\n'
          '\r\n';
          String endPostData = '\r\n--aab03x--';

          File file = new File('./test/image.jpg');
          List<int> fileData = file.readAsBytesSync();

          List<int> sendData = new List<int>();
          sendData..addAll(postData.codeUnits)..addAll(CryptoUtils.bytesToBase64(fileData).codeUnits)..addAll(endPostData.codeUnits);

          request.contentLength = sendData.length;
          request.add(sendData);
          return request.close();

        }).then((HttpClientResponse response) {
          response.transform(new Utf8Decoder())
          .transform(new LineSplitter())
          .listen((String result) {
            finalString += result;
          },
          onDone: () {
            expect(finalString, equals('Form File Upload POST OK'));

            File sentFile = new File('./test/image.jpg');
            List<int> sentFileData = sentFile.readAsBytesSync();

            File receivedFile = new File('./test/r-image.jpg');
            List<int> receivedFileData = receivedFile.readAsBytesSync();

            for(int i = 0; i < sentFileData.length; i++) {
              expect(sentFileData[i], equals(receivedFileData[i]));
            }
          });
        });
      });
      atest();
    });

    test('[POST] Simple POST Request with Post Binary Data MultiPart', () {
      String finalString = '';
      var atest = expectAsync0(() {
        client.post('127.0.0.1', 3333, '/postData').then((HttpClientRequest request) {
          request.headers.contentType = new ContentType('multipart', 'form-data', charset: 'utf-8', parameters: {'boundary':'AaB03x'});

          String postData =  '--AaB03x\r\n'
                             'Content-Disposition: form-data; name="submit-name"\r\n'
                             '\r\n'
                             'Larry\r\n'
                             '--AaB03x\r\n'
                             'Content-Disposition: form-data; name="file"; filename="image.jpg"\r\n'
                             'Content-Type: image/jpeg\r\n'
                             'Content-Transfer-Encoding: binary\r\n'
                             '\r\n';
          String endPostData = '\r\n--AaB03x--';

          File file = new File('./test/image.jpg');
          List<int> fileData = file.readAsBytesSync();

          List<int> sendData = new List<int>();
          sendData..addAll(postData.codeUnits)..addAll(fileData)..addAll(endPostData.codeUnits);


          request.contentLength = sendData.length;
          request.add(sendData);
          return request.close();

        }).then((HttpClientResponse response) {
          response.transform(new Utf8Decoder())
          .transform(new LineSplitter())
          .listen((String result) {
            finalString += result;
          },
          onDone: () {
            expect(finalString, equals('Form File Upload POST OK'));

            File sentFile = new File('./test/image.jpg');
            List<int> sentFileData = sentFile.readAsBytesSync();

            File receivedFile = new File('./test/r-image.jpg');
            List<int> receivedFileData = receivedFile.readAsBytesSync();

            for(int i = 0; i < sentFileData.length; i++) {
              expect(sentFileData[i], equals(receivedFileData[i]));
            }
          });
        });
      });
      atest();
    });
    return completer.future;
  }
}
