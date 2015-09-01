package thx.load.nodejs;

using thx.promise.Promise;
import thx.Error;
using thx.nodejs.io.Buffers;
import js.node.Fs;
import haxe.io.Bytes;

class File {
  public static function readTextFile(path : String) : Promise<String> {
    return Promise.create(function(resolve, reject) {
      Fs.readFile(path, function(err, content) {
        if(null != err) return reject(Error.fromDynamic(err));
        resolve(content.toString());
      });
    });
  }

  public static function readBinaryFile(path : String) : Promise<Bytes> {
    return Promise.create(function(resolve, reject) {
      Fs.readFile(path, cast "binary", function(err, content : js.node.Buffer) {
        if(null != err) return reject(Error.fromDynamic(err));
        resolve(content.toBytes());
      });
    });
  }
}
