import abe.App;

class Server implements abe.IRoute {
  static function main() {
    var app = new App();
    app.router.register(new Server());
    app.http(4000);
  }

  function new() { }

  @:get("/kill/")
  function kill() {
    response.sendStatus(200);
    js.Node.console.info("Server killed by client");
    js.Node.process.exit(0);
  }
}
