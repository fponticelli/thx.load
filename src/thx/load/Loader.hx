package thx.load;

import haxe.io.Bytes;
import thx.Error;
using thx.Strings;
using thx.promise.Promise;
using thx.http.Request;

class Loader {
  public static function getObject(path : String) : Promise<Dynamic> {
    var ext = path.split(".").pop().toLowerCase();
    return switch ext {
      case "json", "js":
        return getJson(path);
#if yaml
      case "yaml", "yml":
        return getYaml(path);
#end
#if thx_csv
      case "csv":
        return getCsv(path);
#end
      case _:
        return Promise.fail('unrecognized format for $path');
    }
  }

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
#if thx_csv
  public static function getCsv(path : String) : Promise<Array<Array<String>>>
    return getText(path)
      .mapSuccessPromise(function(content) {
        return try {
          Promise.value(thx.csv.Csv.decode(content));
        } catch(e : Dynamic) {
          Promise.error(Error.fromDynamic(e));
        }
      });
#end

  public static function getText(path : String) : Promise<String> {
    if(path.startsWith("http://") || path.startsWith("https://")) {
      return makeTextHttpRequest(path);
    } else if(path.startsWith("file://")) {
      return loadText(path.substring(7));
    } else {
      return throw new Error('unsupported content path or protocol: $path');
    }
  }

  public static function getBinary(path : String) : Promise<Bytes> {
    if(path.startsWith("http://") || path.startsWith("https://")) {
      return makeBinaryHttpRequest(path);
    } else if(path.startsWith("file://")) {
      return loadBinary(path.substring(7));
    } else {
      return throw new Error('unsupported content path or protocol: $path');
    }
  }

#if hxnodejs
  public static function getBuffer(path : String) : Promise<js.node.Buffer> {
    if(path.startsWith("http://") || path.startsWith("https://")) {
      return makeBufferHttpRequest(path);
    } else if(path.startsWith("file://")) {
      return loadBuffer(path.substring(7));
    } else {
      return throw new Error('unsupported content path or protocol: $path');
    }
  }
#end

  public static function normalizePath(path : String) {
    if(path.startsWith('http://') || path.startsWith('https://') || path.startsWith('file://'))
      return path;
#if js
    var host : String = untyped __js__("(typeof window != 'undefined') ? window.location.host : null");
    if(null != host) {
      return '${untyped __js__("window.location.protocol")}//$host$path';
    }
#end
    return 'file://$path';
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

  static function makeBinaryHttpRequest(url : String) : Promise<Bytes> {
    return Request.get(url)
      .mapSuccessPromise(function(response) {
        return switch response.statusCode {
          case 200, 201, 202, 203, 206:
            response.asBytes();
          case 204, 205: // nocontent
            Promise.value(null);
          case _:
            Promise.fail(response.statusText);
        };
      });
  }

  static function loadText(path : String) : Promise<String> {
#if hxnodejs
    return thx.load.nodejs.File.readText(path);
#elseif sys
    return Promise.value(sys.io.File.getContent(path));
#else
    return Promise.fail("this target doesn't support loading files from the filesystem");
#end
  }

  static function loadBinary(path : String) : Promise<Bytes> {
#if hxnodejs
    return thx.load.nodejs.File.readBinary(path);
#elseif sys
    return Promise.value(sys.io.File.getBytes(path));
#else
    return Promise.fail("this target doesn't support loading files from the filesystem");
#end
  }

#if hxnodejs
  static function makeBufferHttpRequest(url : String) : Promise<js.node.Buffer> {
    return makeBinaryHttpRequest(url)
      .mapSuccess(function(content) {
        return content.getData();
      });
  }

  static function loadBuffer(path : String) : Promise<js.node.Buffer> {
    return thx.load.nodejs.File.readBuffer(path);
  }
#end
}
