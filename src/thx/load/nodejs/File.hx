package thx.load.nodejs;

using thx.promise.Promise;
import thx.Error;
import js.node.Fs;

class File {
  public static function readTextFile(path : String) : Promise<String> {
    return Promise.create(function(resolve, reject) {
      Fs.readFile(path, function(err, content) {
        if(null != err) return reject(Error.fromDynamic(err));
        resolve(content.toString());
      });
    });
  }
}
