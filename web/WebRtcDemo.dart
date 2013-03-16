import 'dart:html';

void main() {
  var video = query('#webcam') as VideoElement;
  window.navigator.getUserMedia(video: true).then((stream) {
    video
    ..autoplay = true
    ..src = Url.createObjectUrl(stream)
    ..onLoadedMetadata.listen((e) {
      
    });
});
}

