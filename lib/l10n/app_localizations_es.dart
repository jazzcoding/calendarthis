// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => '¡CalendarThis!';

  @override
  String get extractFromText => 'Extraer de texto';

  @override
  String get scanFromImage => 'Escanear desde imagen';

  @override
  String get createNewEvent => 'Crear nuevo evento';

  @override
  String get viewMyEvents => 'Ver mis eventos';

  @override
  String get settings => 'Configuración';

  @override
  String get enterOrPasteText => 'Ingrese o pegue texto';

  @override
  String get pasteTextHint =>
      'Pegue un correo electrónico, mensaje o cualquier texto que contenga detalles del evento...';

  @override
  String get pasteFromClipboard => 'Pegar desde el portapapeles';

  @override
  String get clear => 'Limpiar';

  @override
  String get extractEventDetails => 'Extraer detalles del evento';

  @override
  String get extractEventDetailsWithAI => 'Extraer detalles del evento con IA';

  @override
  String get extractingEventDetails => 'Extrayendo detalles del evento...';

  @override
  String get extractingEventDetailsWithAI =>
      'Extrayendo detalles del evento con IA...';

  @override
  String get usingOpenRouterAI => 'Usando OpenRouter IA para mayor precisión';

  @override
  String get extractedEventDetails => 'Detalles del evento extraídos';

  @override
  String get eventTitle => 'Título del evento';

  @override
  String get description => 'Descripción';

  @override
  String get location => 'Ubicación';

  @override
  String get dateAndTime => 'Fecha y hora';

  @override
  String get startDate => 'Fecha de inicio';

  @override
  String get startTime => 'Hora de inicio';

  @override
  String get endDate => 'Fecha de finalización';

  @override
  String get endTime => 'Hora de finalización';

  @override
  String get attendees => 'Asistentes';

  @override
  String get createEvent => 'Crear evento';

  @override
  String get editSourceText => 'Editar texto fuente';

  @override
  String get eventCreatedSuccessfully => '¡Evento creado con éxito!';

  @override
  String get failedToCreateEvent =>
      'Error al crear el evento. Por favor, inténtelo de nuevo.';

  @override
  String errorCreatingEvent(String error) {
    return 'Error al crear el evento: $error';
  }

  @override
  String errorPreparingEvent(String error) {
    return 'Error al preparar el evento: $error';
  }

  @override
  String get calendarPermissionRequired =>
      'Se requiere permiso de calendario para crear eventos.';

  @override
  String get noCalendarsAvailable =>
      'No hay calendarios disponibles. Por favor, añada un calendario a su dispositivo.';

  @override
  String usingCalendar(String calendarName) {
    return 'Usando calendario: $calendarName';
  }

  @override
  String get takePicture => 'Tomar foto';

  @override
  String get gallery => 'Galería';

  @override
  String get extractText => 'Extraer texto';

  @override
  String get processing => 'Procesando...';

  @override
  String get scanDocument => 'Escanear documento';

  @override
  String get takePictureOrSelectImage =>
      'Tome una foto o seleccione una imagen\nque contenga detalles del evento';

  @override
  String get processingImage => 'Procesando imagen...';

  @override
  String get cameraPermissionRequired =>
      'Se requiere permiso de cámara para usar esta función.';

  @override
  String get pleaseSelectImage =>
      'Por favor, tome o seleccione una imagen primero.';

  @override
  String errorTakingPicture(String error) {
    return 'Error al tomar la foto: $error';
  }

  @override
  String errorPickingImage(String error) {
    return 'Error al seleccionar la imagen: $error';
  }

  @override
  String errorProcessingImage(String error) {
    return 'Error al procesar la imagen: $error';
  }
}
