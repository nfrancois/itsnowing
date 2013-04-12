import 'dart:html';
import 'dart:math';


void main() {
  CanvasElement canvas = query("#canvasSnow");
  InputElement flakesRange =  query("#flakesRange");
  ButtonElement takePhoto = query("#takePhoto");
  VideoElement video = query('#webcam');
  CanvasElement photoBuffer = query("#photoBuffer");
  
  var photoContent = query("#photoContent");
  var content = query("#content");
  var acceptVideo = query("#acceptVideo");
  var versionInfo = query("#versionInfo");
  
  takePhoto.onClick.listen((e) => _takePhoto(video, canvas, photoBuffer, photoContent));
  var snow = new Snow(canvas.context2d, canvas.width, canvas.height, int.parse(flakesRange.value));
  flakesRange.onChange.listen((e) => snow.numberOfFlake = int.parse(flakesRange.value));
  
  window.navigator.getUserMedia(video: true)
  ..catchError((e) => _displayError("Unable to access the camera. Did you have one ?"))
  ..then((LocalMediaStream stream) {
    video
    ..autoplay = true
    ..src = Url.createObjectUrl(stream)
    ..onLoadedMetadata.listen((e) => _start(versionInfo, acceptVideo, content, snow));
  });

}

_displayError(String message){
  query("#acceptVideo")..classes.add("hide");
  query("#error")..innerHtml= message
                 ..classes.remove("hide");
}

_takePhoto(VideoElement video, CanvasElement canvas, CanvasElement photoBuffer, Element photoContent){
  // remove previous if exist
  var previousImage = photoContent.query("img");
  if(previousImage != null){
    previousImage.remove();
  }
  // Create photo un buffer
  CanvasRenderingContext2D photoContext = photoBuffer.context2d;
  photoContext.drawImage(video, 0, 0);
  photoContext.drawImage(canvas, 0, 0);
  var data = photoBuffer.toDataUrl("image/png");
  // Output in new image
  ImageElement photo = new Element.tag("img");
  photoContent.append(photo);
  photo..height = canvas.height~/2
       ..width = canvas.width~/2
       ..src = data;  
}

_start(Element versionInfo, Element acceptVideo, Element content, Snow snow){
  versionInfo.classes.add("hide");
  acceptVideo.classes.add("hide");
  content.classes.remove("hide");
  snow.start();  
}

class Snow {
 
  int numberOfFlake;
  final CanvasRenderingContext2D ctx;
  final int width;
  final int heigth;
  
  final List<Flake> flakes;
  Random _random;
  
  Snow(this.ctx, this.width, this.heigth, this.numberOfFlake) : flakes = [] {
    _random = new Random();
    for(int i=0; i<numberOfFlake; i++){
      _createFlake();
    }
  }
  
  _createFlake(){
    // Create flake with random properties
    var size = _random.nextInt(5) + 2;
    var speedX = _random.nextInt(3);
    var speedY = _random.nextInt(5) + 2;
    var x = _random.nextInt(width);
    var y = _random.nextInt(heigth);      
    flakes.add(new Flake(x, y, size, speedX, speedY));
  }
  
  start() => window.animationFrame.then(_animate);
  
  _animate(num time){
    draw();
    window.animationFrame.then(_animate);    
  }
  
  draw(){
    ctx.clearRect(0, 0, width, heigth);
    for(Flake flake in flakes){
      flake..draw(ctx)
           ..updatePosition();
    }
    // Remove unvisible flakes and recreate new
    flakes.removeWhere((Flake flake)  => flake.y > heigth || flake.y > heigth);
    for(int i=0; i<numberOfFlake-flakes.length; i++){
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

