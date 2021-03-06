import utest.UTest;

import utest.Assert;
import thx.Path;
import thx.Url;
import thx.load.Loader;
import js.Node;

class TestAll {
  static var cwd : Path = Node.process.cwd();
  static var fileText = cwd / "assets/test.txt";
  static var fileJson = cwd / "assets/sample.json";
  static var fileYaml = cwd / "assets/sample.yaml";
  static var host : Url = 'http://localhost:1651';
  static var httpText = host / "text";
  static var httpJson = host / "json";
  static var httpYaml = host / "yaml";

  public function new() {}

  public function testFailLoadFromFile() {
    assertPathFailLoad("file:///ISHOULDNOTEXIST$$$$");
  }

  public function testFailLoadFromHttp() {
    assertPathFailLoad("http://www.google.com/notaresource");
  }

  public function testLoadFromFile() {
    assertPathLoadsWithContent('file://$fileText', "Lorem ipsum");
  }

  public function testLoadFromHttp() {
    assertPathLoadsWithContent(httpText, "Lorem ipsum");
  }

  public function testLoadJsonFromHttp() {
    assertPathLoadsJson(httpJson, "glossary.title", "example glossary");
  }

  public function testLoadYamlFromHttp() {
    assertPathLoadsYaml(httpYaml, "bill-to.family", "Dumars");
  }

  function assertPathLoadsJson(path : String, field : String, value : String, ?pos : haxe.PosInfos) {
    var done = Assert.createAsync(2000);
    Loader.getJson(path)
      .success(function(response) {
        Assert.isTrue(value == thx.Objects.getPath(response, field), 'expected value $value at $field for $response', pos);
      })
      .failure(function(err) Assert.fail(err.toString(), pos))
      .always(done);
  }

  function assertPathLoadsYaml(path : String, field : String, value : String, ?pos : haxe.PosInfos) {
    var done = Assert.createAsync(2000);
    Loader.getYaml(path)
      .success(function(response) {
        Assert.isTrue(value == thx.Objects.getPath(response, field), 'expected value $value at $field for $response', pos);
      })
      .failure(function(err) Assert.fail(err.toString(), pos))
      .always(done);
  }

  function assertPathLoadsWithContent(path : String, content : String, ?pos : haxe.PosInfos) {
    var done = Assert.createAsync(2000);
    Loader.getText(path)
      .success(function(response) {
        Assert.stringContains(content, response, pos);
      })
      .failure(function(err) Assert.fail(err.toString(), pos))
      .always(done);
  }

  function assertPathFailLoad(path : String, ?pos : haxe.PosInfos) {
    var done = Assert.createAsync(2000);
    Loader.getText(path)
      .success(function(response) {
        trace(response);
        Assert.fail("path should not load any resource", pos);
      })
      .failure(function(err) Assert.isTrue(err.toString().length > 0, pos))
      .always(done);
  }

  public static function main() {
    UTest.run([
      new TestAll()
    ]);
  }
}
