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
    ..onLoadedMetadata.listen((e) {
      snow.start();
    });
  });

}

class Snow {
  const int NUMBER_OF_FLAKE = 25;
 
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
    var randomSize = _random.nextInt(5) + 2;
    var randomX = _random.nextInt(width);
    var randomY = _random.nextInt(heigth);      
    flakes.add(new Flake(randomSize, randomSize, randomX, randomY));
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
  
  final num speed;
  final num size;
  num x;
  num y;
  
  Flake(this.speed, this.size, this.x, this.y);
  
  updatePosition(){
    this.x += speed;
    this.y += speed;   
  }
  
  draw(CanvasRenderingContext2D ctx){
    ctx..beginPath()
      ..arc(x, y, this.size, 0, PI*2, false)
      ..fillStyle = "#FFF"
      ..fill();    
  }
  
}

