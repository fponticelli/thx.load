package thx.load;

import thx.Error;

using thx.Strings;
using thx.promise.Promise;
using thx.http.Request;

class Loader {
  public static function getJson(path : String) : Promise<Dynamic>
    return getText(path)
      .mapSuccessPromise(function(content) {
        return try {
          Promise.value(haxe.Json.parse(content));
        } catch(e : Dynamic) {
          Promise.error(Error.fromDynamic(e));
        }
      });

#if yaml
  public static function getYaml(path : String, ?options : yaml.Parser.ParserOptions) : Promise<Dynamic> {
    if(null == options) {
      options = yaml.Parser.options().useObjects();
    }
    return getText(path)
      .mapSuccessPromise(function(content) {
        return try {
          Promise.value(yaml.Yaml.parse(content, options));
        } catch(e : Dynamic) {
          Promise.error(Error.fromDynamic(e));
        }
      });
  }
#end

  public static function getText(path : String) : Promise<String> {
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
        return switch response.statusCode {
          case 200, 201, 202, 203, 206:
            response.asString();
          case 204, 205: // nocontent
            Promise.value(null);
          case _:
            Promise.fail(response.statusText);
        };
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
