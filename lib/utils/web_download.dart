/// Punto de entrada con export condicional.
/// En web activa dart:html; en otras plataformas usa el stub.
export 'web_download_stub.dart'
    if (dart.library.html) 'web_download_web.dart';
