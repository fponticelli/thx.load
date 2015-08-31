import utest.UTest;

import utest.Assert;
import thx.Path;
import thx.Url;
import thx.load.Loader;
import js.Node;

class TestAll {
  static var cwd : Path = Node.process.cwd();
  static var fileText = cwd / "assets/test.txt";
  static var host : Url = 'http://localhost:4000';
  static var httpText = host / "text";

  public function new() {}

  public function testLoadFromFile() {
    assertPathLoadsWithContent('file://$fileText', "Lorem ipsum");
  }

  public function testLoadFromHttp() {
    assertPathLoadsWithContent(httpText, "Lorem ipsum");
  }

  function assertPathLoadsWithContent(path : String, content : String) {
    var done = Assert.createAsync();
    Loader.getText(path)
      .success(function(response) {
        Assert.stringContains(content, response);
      })
      .failure(function(err) Assert.fail(err.toString()))
      .always(done);
  }

  public static function main() {
    UTest.run([
      new TestAll()
    ]);
  }
}
