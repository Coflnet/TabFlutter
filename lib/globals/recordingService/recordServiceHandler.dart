import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:opus_dart/opus_dart.dart';
import 'package:opus_flutter/opus_flutter.dart' as opus_flutter;
import 'package:permission_handler/permission_handler.dart';
import 'package:table_entry/src/vad/audio_utils.dart';
import '../../src/vad/vad_handler.dart';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as soi;
import 'package:record/record.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../recentLogRequest/recentLogHandler.dart';
import '../recentLogRequest/recentLogRequest.dart';
import 'recordingServer.dart';

const String _kStopAction = 'action.stop';

@pragma('vm:entry-point')
void startRecordService() {
  FlutterForegroundTask.setTaskHandler(RecordServiceHandler());
}

late soi.Socket? ws;

class RecordServiceHandler extends TaskHandler {
  final AudioRecorder _recorder = AudioRecorder();

  Uint8List audioBuffer = Uint8List(0);
  StreamSubscription? audioStream;
  StreamController<Uint8List> _audioStreamController =
      StreamController<Uint8List>();
  String reconizedWords = "";
  StreamSubscription? _mRecordingDataSubscription;
  late WebSocketChannel channel;
  String? _mPath;
  late SimpleOpusEncoder encoder;
  late SimpleOpusDecoder decoder;
  final record = AudioRecorder();
  int newNum = 0;
  final _vadHandler = VadHandler.create(isDebug: true);

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    try {
      initOpus(await opus_flutter
          .load()); // init opus in background task (its separate isolate)
      await _startRecorder();
    } catch (e) {
      print("-------------------------\nError starting recorder: $e");
    }
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // not use
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    await _stopRecorder();
  }

  @override
  void onNotificationButtonPressed(String id) async {
    if (id == _kStopAction) {
      FlutterForegroundTask.sendDataToMain('stop');
    }
  }

  Future<void> connectSocket() async {
    await setupEncoder();

    FlutterForegroundTask.updateService(
      notificationText: 'connecting',
      notificationButtons: [
        const NotificationButton(id: _kStopAction, text: 'stop'),
      ],
    );
    newNum = 1;
    String userLocale = Platform.localeName;
    channel = WebSocketChannel.connect(
        Uri.parse("wss://tab.coflnet.com/api/audio?language=$userLocale"));
    await channel.ready;
    channel.stream.listen((message) {
      _handleMessage(message);
    });
    FlutterForegroundTask.updateService(
      notificationText: 'connected',
      notificationButtons: [
        const NotificationButton(id: _kStopAction, text: 'stop'),
      ],
    );
    return;
  }

  setupEncoder() async {
    print("setup encoder");
    encoder = SimpleOpusEncoder(
        sampleRate: 16000, channels: 1, application: Application.voip);
    print("setup decoder");
    decoder = SimpleOpusDecoder(sampleRate: 16000, channels: 1);
  }

  void _handleMessage(dynamic message) {
    final response = jsonDecode(message);
    if (response["type"] == "transcript") {
      reconizedWords = "${response["content"]} $reconizedWords ";
    }
  }

  void sendMessage(data) async {
    try {
      channel.sink.add(data);
      print("Message sent: ${data.length}");
    } catch (e) {
      print("Error sending message: $e");
    }
    if (ws?.connected == true) {
      print("hi");
      ws?.emit(data);
    }
  }

  Future<void> _startRecorder() async {
    _vadHandler.onSpeechStart.listen((_) {
      print('Speech detected.');
      FlutterForegroundTask.updateService(
        notificationText: 'speaking',
        notificationButtons: [
          const NotificationButton(id: _kStopAction, text: 'stop'),
        ],
      );
    });

    _vadHandler.onSpeechEnd.listen((List<double> samples) {
      FlutterForegroundTask.updateService(
        notificationText: 'spoke ${samples.length / 16000} seconds',
        notificationButtons: [
          const NotificationButton(id: _kStopAction, text: 'stop'),
        ],
      );
      var url = AudioUtils.createWavUrl(samples);
      print(
          'Speech ended, first 10 samples: ${samples.take(10).toList()} length: ${samples.length}');
      FlutterForegroundTask.sendDataToMain(url);
    });

    _vadHandler.onVADMisfire.listen((_) {
      FlutterForegroundTask.updateService(
        notificationText: 'too short, ignoring',
        notificationButtons: [
          const NotificationButton(id: _kStopAction, text: 'stop'),
        ],
      );
      print('VAD misfire detected.');
    });

    _vadHandler.onError.listen((String message) {
      print('Error: $message');
    });
    FlutterForegroundTask.updateService(
      notificationText: 'vad start',
      notificationButtons: [
        const NotificationButton(id: _kStopAction, text: 'stop'),
      ],
    );

    _vadHandler.startListening();
    return;

    FlutterForegroundTask.updateService(
      notificationText: 'setup',
      notificationButtons: [
        const NotificationButton(id: _kStopAction, text: 'stop'),
      ],
    );
    // start recorder
    await connectSocket();
    FlutterForegroundTask.updateService(
      notificationText: 'connected',
      notificationButtons: [
        const NotificationButton(id: _kStopAction, text: 'stop'),
      ],
    );
    final tempDir = await getDownloadsDirectory();

    final dir = "${tempDir!.path}/audio";

    File(dir).createSync(
      recursive: true,
    );
    var sink = await createFile("original.pcm");
    const int chunkSize = 960;
    List<Uint8List> opusFrameBuffer = [];
    const int opusFramesPerPage = 8;

    Uint8List idHeader = createOpusIdentificationHeader();

    Uint8List oggPage = createOggPage([idHeader], isFirst: true);

    sink.add(oggPage);
    channel.sink.add(oggPage);

    Uint8List commentHeader = createOpusCommentHeader();

    Uint8List commentPage = createOggPage([commentHeader]);

    sink.add(commentPage);
    channel.sink.add(commentPage);

    final stream = await record.startStream(const RecordConfig(
        sampleRate: 16000, encoder: AudioEncoder.pcm16bits, numChannels: 1));

    FlutterForegroundTask.updateService(
      notificationText: 'starging recorder',
      notificationButtons: [
        const NotificationButton(id: _kStopAction, text: 'stop'),
      ],
    );
    _mRecordingDataSubscription =
        bufferStream(stream, chunkSize).listen((chunk) {
      var input = Int16List.fromList(chunk);
      var opusData = encoder.encode(input: input);

      opusFrameBuffer.add(opusData);

      if (opusFrameBuffer.length == opusFramesPerPage) {
        var oggPage = createOggPage(
          opusFrameBuffer,
          isFirst: sequenceNumber == 0,
        );

        sink.add(oggPage);
        channel.sink.add(oggPage);

        opusFrameBuffer.clear();
        print("sent ogg page " +
            oggPage.length.toString() +
            " bytes " +
            (channel.closeCode?.toString() ?? ""));
      }
    });

    // create stop action button
    FlutterForegroundTask.updateService(
      notificationText: 'recording...r',
      notificationButtons: [
        const NotificationButton(id: _kStopAction, text: 'stop'),
      ],
    );
  }

  Future<IOSink> createFile(String name) async {
    var tempDir = await getDownloadsDirectory();
    _mPath = '${tempDir!.path}/$name';
    var outputFile = File(_mPath!);
    if (outputFile.existsSync()) {
      await outputFile.delete();
    }
    return outputFile.openWrite();
  }

  Future<void> _stopRecorder() async {
    // stop recorder
    await _recorder.stop();
    await _recorder.dispose();
  }
}

Stream<List<int>> bufferStream(Stream<Uint8List> inputStream, int chunkSize) {
  StreamController<List<int>>? controller;
  List<int> buffer = [];

  controller = StreamController<List<int>>(onListen: () {
    inputStream.listen((newData) {
      if (newData.offsetInBytes % Int16List.bytesPerElement == 0) {
        var int16List = newData.buffer
            .asInt16List(newData.offsetInBytes, newData.lengthInBytes ~/ 2);
        buffer.addAll(int16List);
      } else {
        Uint8List alignedData = Uint8List.fromList(newData);

        var int16List = alignedData.buffer.asInt16List();
        buffer.addAll(int16List);
      }

      while (buffer.length >= chunkSize) {
        var chunk = buffer.sublist(0, chunkSize);
        buffer = buffer.sublist(chunkSize);
        controller!.add(chunk);
      }
    }, onDone: () {
      if (buffer.isNotEmpty) {
        controller!.add(buffer);
      }
      controller!.close();
    }, onError: (error) {
      controller!.addError(error);
    });
  });

  return controller.stream;
}

const int oggHeaderSize = 27;
const int oggMaxSegmentCount = 255;
const int oggMaxSegmentSize = 255;

int sequenceNumber = 0;
int granulePosition = 0;
int streamSerialNumber = 0xABCD1234; // Randomly chosen

Uint8List createOggPage(List<Uint8List> opusFrames,
    {bool isFirst = false, bool isLast = false}) {
  // Collect segment sizes and packet data
  List<int> segmentTable = [];
  List<int> pageBody = [];

  for (var frame in opusFrames) {
    int frameSize = frame.length;
    int segments = (frameSize / oggMaxSegmentSize).ceil();

    if (segmentTable.length + segments > oggMaxSegmentCount) {
      throw Exception('Too many segments for a single Ogg page');
    }

    int remaining = frameSize;
    int offset = 0;

    while (remaining > 0) {
      int segmentSize =
          remaining > oggMaxSegmentSize ? oggMaxSegmentSize : remaining;
      segmentTable.add(segmentSize);
      pageBody.addAll(frame.sublist(offset, offset + segmentSize));
      remaining -= segmentSize;
      offset += segmentSize;
    }
  }

  int pageSize = oggHeaderSize + segmentTable.length + pageBody.length;
  Uint8List pageData = Uint8List(pageSize);
  ByteData header = pageData.buffer.asByteData();

  header.setUint8(0, 0x4F);
  header.setUint8(1, 0x67);
  header.setUint8(2, 0x67);
  header.setUint8(3, 0x53);

  header.setUint8(4, 0x00);

  int headerType = 0;
  if (isFirst) headerType |= 0x02; // Beginning of stream
  if (isLast) headerType |= 0x04; // End of stream
  header.setUint8(5, headerType);

  header.setUint64(6, granulePosition, Endian.little);

  header.setUint32(14, streamSerialNumber, Endian.little);

  header.setUint32(18, sequenceNumber, Endian.little);

  header.setUint32(22, 0, Endian.little);

  header.setUint8(26, segmentTable.length);

  for (int i = 0; i < segmentTable.length; i++) {
    header.setUint8(oggHeaderSize + i, segmentTable[i]);
  }

  int bodyOffset = oggHeaderSize + segmentTable.length;
  pageData.setRange(bodyOffset, bodyOffset + pageBody.length, pageBody);

  int checksum = calculateOggChecksum(pageData);
  header.setUint32(22, checksum, Endian.little);

  sequenceNumber++;
  granulePosition += opusFrames.length * 960;

  return pageData;
}

Uint8List createOpusIdentificationHeader() {
  Uint8List header = Uint8List(19);
  ByteData data = header.buffer.asByteData();

  header.setRange(0, 8, [0x4F, 0x70, 0x75, 0x73, 0x48, 0x65, 0x61, 0x64]);

  data.setUint8(8, 1);

  data.setUint8(9, 1);

  data.setUint16(10, 0, Endian.little);

  data.setUint32(12, 16000, Endian.little);

  data.setUint16(16, 0, Endian.little);

  data.setUint8(18, 0);

  return header;
}

Uint8List createOpusCommentHeader() {
  List<int> header = [0x4F, 0x70, 0x75, 0x73, 0x54, 0x61, 0x67, 0x73];

  header.addAll([0x00, 0x00, 0x00, 0x00]);

  header.addAll([0x00, 0x00, 0x00, 0x00]);

  return Uint8List.fromList(header);
}

int calculateOggChecksum(Uint8List data) {
  int crc = 0;
  for (var byte in data) {
    crc = ((crc << 8) ^ crcTable[((crc >> 24) & 0xFF) ^ byte]) & 0xFFFFFFFF;
  }
  return crc;
}

const List<int> crcTable = [
  0x00000000,
  0x04c11db7,
  0x09823b6e,
  0x0d4326d9,
  0x130476dc,
  0x17c56b6b,
  0x1a864db2,
  0x1e475005,
  0x2608edb8,
  0x22c9f00f,
  0x2f8ad6d6,
  0x2b4bcb61,
  0x350c9b64,
  0x31cd86d3,
  0x3c8ea00a,
  0x384fbdbd,
  0x4c11db70,
  0x48d0c6c7,
  0x4593e01e,
  0x4152fda9,
  0x5f15adac,
  0x5bd4b01b,
  0x569796c2,
  0x52568b75,
  0x6a1936c8,
  0x6ed82b7f,
  0x639b0da6,
  0x675a1011,
  0x791d4014,
  0x7ddc5da3,
  0x709f7b7a,
  0x745e66cd,
  0x9823b6e0,
  0x9ce2ab57,
  0x91a18d8e,
  0x95609039,
  0x8b27c03c,
  0x8fe6dd8b,
  0x82a5fb52,
  0x8664e6e5,
  0xbe2b5b58,
  0xbaea46ef,
  0xb7a96036,
  0xb3687d81,
  0xad2f2d84,
  0xa9ee3033,
  0xa4ad16ea,
  0xa06c0b5d,
  0xd4326d90,
  0xd0f37027,
  0xddb056fe,
  0xd9714b49,
  0xc7361b4c,
  0xc3f706fb,
  0xceb42022,
  0xca753d95,
  0xf23a8028,
  0xf6fb9d9f,
  0xfbb8bb46,
  0xff79a6f1,
  0xe13ef6f4,
  0xe5ffeb43,
  0xe8bccd9a,
  0xec7dd02d,
  0x34867077,
  0x30476dc0,
  0x3d044b19,
  0x39c556ae,
  0x278206ab,
  0x23431b1c,
  0x2e003dc5,
  0x2ac12072,
  0x128e9dcf,
  0x164f8078,
  0x1b0ca6a1,
  0x1fcdbb16,
  0x018aeb13,
  0x054bf6a4,
  0x0808d07d,
  0x0cc9cdca,
  0x7897ab07,
  0x7c56b6b0,
  0x71159069,
  0x75d48dde,
  0x6b93dddb,
  0x6f52c06c,
  0x6211e6b5,
  0x66d0fb02,
  0x5e9f46bf,
  0x5a5e5b08,
  0x571d7dd1,
  0x53dc6066,
  0x4d9b3063,
  0x495a2dd4,
  0x44190b0d,
  0x40d816ba,
  0xaca5c697,
  0xa864db20,
  0xa527fdf9,
  0xa1e6e04e,
  0xbfa1b04b,
  0xbb60adfc,
  0xb6238b25,
  0xb2e29692,
  0x8aad2b2f,
  0x8e6c3698,
  0x832f1041,
  0x87ee0df6,
  0x99a95df3,
  0x9d684044,
  0x902b669d,
  0x94ea7b2a,
  0xe0b41de7,
  0xe4750050,
  0xe9362689,
  0xedf73b3e,
  0xf3b06b3b,
  0xf771768c,
  0xfa325055,
  0xfef34de2,
  0xc6bcf05f,
  0xc27dede8,
  0xcf3ecb31,
  0xcbffd686,
  0xd5b88683,
  0xd1799b34,
  0xdc3abded,
  0xd8fba05a,
  0x690ce0ee,
  0x6dcdfd59,
  0x608edb80,
  0x644fc637,
  0x7a089632,
  0x7ec98b85,
  0x738aad5c,
  0x774bb0eb,
  0x4f040d56,
  0x4bc510e1,
  0x46863638,
  0x42472b8f,
  0x5c007b8a,
  0x58c1663d,
  0x558240e4,
  0x51435d53,
  0x251d3b9e,
  0x21dc2629,
  0x2c9f00f0,
  0x285e1d47,
  0x36194d42,
  0x32d850f5,
  0x3f9b762c,
  0x3b5a6b9b,
  0x0315d626,
  0x07d4cb91,
  0x0a97ed48,
  0x0e56f0ff,
  0x1011a0fa,
  0x14d0bd4d,
  0x19939b94,
  0x1d528623,
  0xf12f560e,
  0xf5ee4bb9,
  0xf8ad6d60,
  0xfc6c70d7,
  0xe22b20d2,
  0xe6ea3d65,
  0xeba91bbc,
  0xef68060b,
  0xd727bbb6,
  0xd3e6a601,
  0xdea580d8,
  0xda649d6f,
  0xc423cd6a,
  0xc0e2d0dd,
  0xcda1f604,
  0xc960ebb3,
  0xbd3e8d7e,
  0xb9ff90c9,
  0xb4bcb610,
  0xb07daba7,
  0xae3afba2,
  0xaafbe615,
  0xa7b8c0cc,
  0xa379dd7b,
  0x9b3660c6,
  0x9ff77d71,
  0x92b45ba8,
  0x9675461f,
  0x8832161a,
  0x8cf30bad,
  0x81b02d74,
  0x857130c3,
  0x5d8a9099,
  0x594b8d2e,
  0x5408abf7,
  0x50c9b640,
  0x4e8ee645,
  0x4a4ffbf2,
  0x470cdd2b,
  0x43cdc09c,
  0x7b827d21,
  0x7f436096,
  0x7200464f,
  0x76c15bf8,
  0x68860bfd,
  0x6c47164a,
  0x61043093,
  0x65c52d24,
  0x119b4be9,
  0x155a565e,
  0x18197087,
  0x1cd86d30,
  0x029f3d35,
  0x065e2082,
  0x0b1d065b,
  0x0fdc1bec,
  0x3793a651,
  0x3352bbe6,
  0x3e119d3f,
  0x3ad08088,
  0x2497d08d,
  0x2056cd3a,
  0x2d15ebe3,
  0x29d4f654,
  0xc5a92679,
  0xc1683bce,
  0xcc2b1d17,
  0xc8ea00a0,
  0xd6ad50a5,
  0xd26c4d12,
  0xdf2f6bcb,
  0xdbee767c,
  0xe3a1cbc1,
  0xe760d676,
  0xea23f0af,
  0xeee2ed18,
  0xf0a5bd1d,
  0xf464a0aa,
  0xf9278673,
  0xfde69bc4,
  0x89b8fd09,
  0x8d79e0be,
  0x803ac667,
  0x84fbdbd0,
  0x9abc8bd5,
  0x9e7d9662,
  0x933eb0bb,
  0x97ffad0c,
  0xafb010b1,
  0xab710d06,
  0xa6322bdf,
  0xa2f33668,
  0xbcb4666d,
  0xb8757bda,
  0xb5365d03,
  0xb1f740b4,
];
