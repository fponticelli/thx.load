package thx.load.nodejs;

using thx.promise.Promise;
import thx.Error;
import js.node.Fs;
import haxe.io.Bytes;

class File {
  public static function readText(path : String) : Promise<String> {
    return Promise.create(function(resolve, reject) {
      Fs.readFile(path, { encoding : "utf8" }, function(err, content) {
        if(null != err) return reject(Error.fromDynamic(err));
        resolve(content);
      });
    });
  }

  public static function readBinary(path : String) : Promise<Bytes>
    return readBuffer(path)
      .mapSuccess(function(buff) return Bytes.ofData(buff));

  public static function readBuffer(path : String) : Promise<js.node.Buffer> {
    return Promise.create(function(resolve, reject) {
      Fs.readFile(path, function(err, content : js.node.Buffer) {
        if(null != err) return reject(Error.fromDynamic(err));
        resolve(content);
      });
    });
  }
}
