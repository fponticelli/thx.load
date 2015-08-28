import utest.UTest;

import thx.Url;
import thx.http.Request;

class TestAll {
  static var host : Url = 'http://localhost:4000';
  public function new() {}

  public function testLoadFromFile() {

  }

  public function testLoadFromHttp() {

  }

  public static function main() {
    UTest.run([
      new TestAll()
    ]);
  }
}
