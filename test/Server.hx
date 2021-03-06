import abe.App;

class Server implements abe.IRoute {
  static function main() {
    var app = new App();
    app.router.register(new Server());
    app.http(1651);
  }

  function new() { }

  @:get("/text")
  function loadText() {
    var content = js.node.Fs.readFileSync("assets/test.txt");
    response.send(content);
  }

  @:get("/json")
  function loadJson() {
    var content = js.node.Fs.readFileSync("assets/sample.json");
    response.send(content);
  }

  @:get("/yaml")
  function loadYaml() {
    var content = js.node.Fs.readFileSync("assets/sample.yaml");
    response.send(content);
  }

  @:get("/kill/")
  function kill() {
    response.sendStatus(200);
    js.Node.console.info("Server killed by client");
    js.Node.process.exit(0);
  }
}
