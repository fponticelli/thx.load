package thx.load;

import thx.Error;

using thx.Strings;
using thx.promise.Promise;
using thx.http.Request;

class Loader {
  public static function getText(path : String) : Promise<String> {
    trace('GO GET: $path');
    if(path.startsWith("http://") || path.startsWith("https://")) {
      return makeTextHttpRequest(path);
    } else if(path.startsWith("file://")) {
      return loadTextFile(path.substring(7));
    } else {
      return throw new Error('unsupported content path or protocol: $path');
    }
  }

  static function makeTextHttpRequest(url : String) : Promise<String> {
    return Request.get(url)
      .mapSuccessPromise(function(response) {
        return response.asString();
      });
  }

  static function loadTextFile(path : String) : Promise<String> {
#if hxnodejs
    return thx.load.nodejs.File.readTextFile(path);
#else
    return Promise.fail("this target doesn't support loading files from the filesystem");
#end
  }
}
