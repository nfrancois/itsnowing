import 'dart:html';
import 'dart:math';


void main() {
  CanvasElement canvas = document.query("#canvas-snow");
  CanvasRenderingContext2D ctx = canvas.getContext("2d");
  var snow = new Snow(ctx, canvas.width, canvas.height);
  var video = query('#webcam') as VideoElement;
  window.navigator.getUserMedia(video: true).then((stream) {
    video
    ..autoplay = true
    ..src = Url.createObjectUrl(stream)
    //..onLoadStart.listen((e) => print("Loading 1"))
    ..onLoadedMetadata.listen((e) => snow.start());
  });

}

class Snow {
  const int NUMBER_OF_FLAKE = 50;
 
  final CanvasRenderingContext2D ctx;
  final int width;
  final int heigth;
  
  final List<Flake> flakes;
  Random _random;
  
  Snow(this.ctx, this.width, this.heigth) : flakes = [] {
    _random = new Random();
    for(int i=0; i<NUMBER_OF_FLAKE; i++){
      _createFlake();
    }
  }
  
  _createFlake(){
    var size = _random.nextInt(5) + 2;
    var speedX = _random.nextInt(3);
    var speedY = _random.nextInt(5) + 2;
    var x = _random.nextInt(width);
    var y = _random.nextInt(heigth);      
    flakes.add(new Flake(x, y, size, speedX, speedY));
  }
  
  start() => window.requestAnimationFrame(_animate);
  
  _animate(num time){
    draw();
    window.requestAnimationFrame(_animate);    
  }
  
  draw(){
    ctx.clearRect(0, 0, width, heigth);
    for(Flake flake in flakes){
      flake.draw(ctx);
      flake.updatePosition();
    }
    // Remove unvisible flakes and recreate new
    flakes.removeMatching((Flake flake)  => flake.y > heigth || flake.y > heigth);
    for(int i=0; i<NUMBER_OF_FLAKE-flakes.length; i++){
      _createFlake();
    }
  }
}

class Flake {
  
  final num size;
  final num speedX;
  final num speedY;
  num x;
  num y;
  
  Flake(this.x, this.y, this.size, this.speedX, this.speedY);
  
  updatePosition(){
    this.x += speedX;
    this.y += speedY;   
  }
  
  draw(CanvasRenderingContext2D ctx){
    ctx..beginPath()
      ..arc(x, y, this.size, 0, PI*2, false)
      ..fillStyle = "#FFF"
      ..fill();    
  }
  
}

