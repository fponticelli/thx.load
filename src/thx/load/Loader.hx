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

  public static function getJson(path : String) : Promise<Dynamic> {
    if(isHttpPath(path)) {
      return Request.getJson(path).body;
    } else if(isFilePath(path)) {
      return loadText(path.substring(7)).map(haxe.Json.parse);
    } else {
      return throw new Error('unsupported content path or protocol: $path');
    }
  }

#if yaml
  public static function getYaml(path : String, ?options : yaml.Parser.ParserOptions) : Promise<Dynamic> {
    if(null == options) {
      options = yaml.Parser.options().useObjects();
    }
    return Request.getText(path)
      .body
      .flatMap(function(content) {
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
      .flatMap(function(content) {
        return try {
          Promise.value(thx.csv.Csv.decode(content));
        } catch(e : Dynamic) {
          Promise.error(Error.fromDynamic(e));
        }
      });
#end

  public static function getText(path : String) : Promise<String>
    return cata(
      function(path) return Request.getText(path).body,
      loadText
    )(path);

  public static function getBinary(path : String) : Promise<Bytes>
    return cata(
      function(path) return Request.getBinary(path).body,
      loadBinary
    )(path);

#if hxnodejs
  public static function getBuffer(path : String) : Promise<js.node.Buffer>
    return cata(
      function(path) return Request.getJSBuffer(path).body,
      loadBuffer
    )(path);
#end

  public static function normalizePath(path : String) {
    if(path.startsWith('http://') || path.startsWith('https://') || path.startsWith('file://'))
      return path;
#if js
    var host : String = untyped __js__("(typeof window != 'undefined') ? window.location.host : null");
    if(null != host) {
      if(!path.startsWith("/"))
        path = (untyped __js__("window.location.pathname") : String).split("/").slice(0, -1).concat([path]).join("/");
      return '${untyped __js__("window.location.protocol")}//$host$path';
    }
#end
    return 'file://$path';
  }

  static function cata<T>(httpHandler : String -> Promise<T>, fileHandler : String -> Promise<T>) : String -> Promise<T> {
    return function(path : String) {
      if(isHttpPath(path))
        return httpHandler(path);
      else if(isFilePath(path))
        return fileHandler(path.substring(7));
      else
        return throw new Error('unsupported protocol for path: $path');
    };
  }

  static function isHttpPath(path : String)
    return path.startsWith("http://") || path.startsWith("https://");

  static function isFilePath(path : String)
    return path.startsWith("file://");

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
  static function loadBuffer(path : String) : Promise<js.node.Buffer>
    return thx.load.nodejs.File.readBuffer(path);
#end
}
