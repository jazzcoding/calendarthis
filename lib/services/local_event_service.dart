import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/event_model.dart';
import 'cache_service.dart';
import 'logging_service.dart';

class LocalEventService {
  static final LocalEventService _instance = LocalEventService._internal();

  factory LocalEventService() {
    return _instance;
  }

  final LoggingService _logger = LoggingService();

  LocalEventService._internal() {
    // Initialize caches
    _eventCache = CacheService<String, EventModel>(
        maxSize: 100, ttlMs: 300000); // 5 minutes TTL
    _allEventsCache =
        CacheService<String, List<EventModel>>(maxSize: 10, ttlMs: 300000);
    _dateRangeEventsCache =
        CacheService<String, List<EventModel>>(maxSize: 20, ttlMs: 300000);

    // Initialize logger
    _logger.init();
  }

  static Database? _database;

  // Caches
  late final CacheService<String, EventModel>
      _eventCache; // Cache for individual events
  late final CacheService<String, List<EventModel>>
      _allEventsCache; // Cache for all events
  late final CacheService<String, List<EventModel>>
      _dateRangeEventsCache; // Cache for date range events

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'calendar_this_events.db');

      await _logger.log('DB', 'Initializing database at path: $path');

      // IMPORTANT: Never delete the database in production code
      // This ensures events persist between app restarts

      return await openDatabase(
        path,
        version: 2, // Increment version for schema update
        onCreate: (db, version) async {
          await _logger.log(
              'DB', 'Creating new database with schema version $version');

          await db.execute('''
          CREATE TABLE events(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT,
            startTime INTEGER NOT NULL,
            endTime INTEGER NOT NULL,
            location TEXT,
            isAllDay INTEGER NOT NULL,
            attendees TEXT,
            reminderMinutes INTEGER NOT NULL,
            originalText TEXT
          )
        ''');

          await _logger.log('DB', 'Database schema created successfully');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          await _logger.log(
              'DB', 'Upgrading database from v$oldVersion to v$newVersion');

          if (oldVersion < 2) {
            try {
              // Check if originalText column already exists
              final result = await db.rawQuery('PRAGMA table_info(events)');
              final columns =
                  result.map((col) => col['name'] as String).toList();

              if (!columns.contains('originalText')) {
                // Add originalText column to existing database
                await db
                    .execute('ALTER TABLE events ADD COLUMN originalText TEXT');
                await _logger.log(
                    'DB', 'Added originalText column to events table');
              } else {
                await _logger.log('DB', 'originalText column already exists');
              }
            } catch (e) {
              await _logger.log('DB', 'Error during schema upgrade: $e');

              // Create a new table with the correct schema if upgrade fails
              try {
                await _logger.log(
                    'DB', 'Attempting table recreation as fallback');

                // Backup existing data
                final events = await db.query('events');
                await _logger.log('DB', 'Backed up ${events.length} events');

                await db.execute('DROP TABLE IF EXISTS events');
                await db.execute('''
                CREATE TABLE events(
                  id TEXT PRIMARY KEY,
                  title TEXT NOT NULL,
                  description TEXT,
                  startTime INTEGER NOT NULL,
                  endTime INTEGER NOT NULL,
                  location TEXT,
                  isAllDay INTEGER NOT NULL,
                  attendees TEXT,
                  reminderMinutes INTEGER NOT NULL,
                  originalText TEXT
                )
              ''');

                // Restore data
                for (var event in events) {
                  await db.insert('events', event);
                }

                await _logger.log(
                    'DB', 'Table recreated and data restored successfully');
              } catch (recreateError) {
                await _logger.log(
                    'DB', 'Error recreating table: $recreateError');
              }
            }
          }
        },
        onOpen: (db) async {
          await _logger.log('DB', 'Database opened successfully');

          // Verify the database schema
          try {
            final result = await db.rawQuery('PRAGMA table_info(events)');
            await _logger.log(
                'DB', 'Database schema verified: ${result.length} columns');
          } catch (e) {
            await _logger.log('DB', 'Error verifying schema: $e');
          }
        },
      );
    } catch (e) {
      await _logger.log('DB', 'Error initializing database: $e');
      // Rethrow to be handled by the caller
      rethrow;
    }
  }

  // Save an event to the local database
  Future<bool> saveEvent(EventModel event) async {
    try {
      await _logger.log('DB', 'Saving event: ${event.id} - ${event.title}');

      final db = await database;

      // Convert event to map
      final eventMap = event.toMap();

      // Log the event data for debugging
      await _logger.log('DB',
          'Event data: startTime=${event.startTime}, endTime=${event.endTime}');

      // Insert with explicit error handling and retry logic
      int retryCount = 0;
      const maxRetries = 3;
      bool success = false;

      while (retryCount < maxRetries && !success) {
        try {
          await db.insert(
            'events',
            eventMap,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

          success = true;
          await _logger.log('DB', 'Event inserted into database successfully');

          // Verify the event was saved
          final savedEvent = await db.query(
            'events',
            where: 'id = ?',
            whereArgs: [event.id],
          );

          if (savedEvent.isNotEmpty) {
            await _logger.log('DB', 'Event verified in database');
          } else {
            await _logger.log(
                'DB', 'Event not found in database after insert!');
            success = false;
          }
        } catch (insertError) {
          retryCount++;
          await _logger.log('DB',
              'Error inserting event (attempt $retryCount): $insertError');

          if (retryCount >= maxRetries) {
            rethrow; // Rethrow to be caught by the outer try-catch
          }

          // Wait before retrying
          await Future.delayed(Duration(milliseconds: 500 * retryCount));
        }
      }

      if (!success) {
        await _logger.log(
            'DB', 'Failed to save event after $maxRetries attempts');
        return false;
      }

      // Update cache
      _eventCache.put(event.id, event);

      // Invalidate list caches since they're now outdated
      _allEventsCache.clear();
      _dateRangeEventsCache.clear();

      await _logger.log('DB', 'Event saved successfully');

      return true;
    } catch (e) {
      await _logger.log('DB', 'Error saving event: $e');

      // Try a direct database operation as a last resort
      try {
        final db = await database;
        final eventMap = event.toMap();

        await _logger.log(
            'DB', 'Attempting direct database operation as fallback');

        await db.insert(
          'events',
          eventMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        await _logger.log('DB', 'Direct database operation succeeded');
        return true;
      } catch (directError) {
        await _logger.log(
            'DB', 'Direct database operation failed: $directError');
        return false;
      }
    }
  }

  // Get all events from the local database
  Future<List<EventModel>> getAllEvents() async {
    try {
      // Check cache first
      final cachedEvents = _allEventsCache.get('all_events');
      if (cachedEvents != null) {
        // No debug printing
        return cachedEvents;
      }

      // Cache miss, query database
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('events');

      final events = List.generate(maps.length, (i) {
        final event = EventModel.fromMap(maps[i]);
        // Update individual event cache
        _eventCache.put(event.id, event);
        return event;
      });

      // Update cache
      _allEventsCache.put('all_events', events);

      return events;
    } catch (e) {
      // No debug printing
      return [];
    }
  }

  // Get events for a specific date range
  Future<List<EventModel>> getEventsInRange(
      DateTime start, DateTime end) async {
    try {
      // Create a cache key for this date range
      final cacheKey =
          '${start.millisecondsSinceEpoch}_${end.millisecondsSinceEpoch}';

      // Check cache first
      final cachedEvents = _dateRangeEventsCache.get(cacheKey);
      if (cachedEvents != null) {
        // No debug printing
        return cachedEvents;
      }

      // Cache miss, query database
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'events',
        where: 'startTime >= ? AND endTime <= ?',
        whereArgs: [
          start.millisecondsSinceEpoch,
          end.millisecondsSinceEpoch,
        ],
      );

      final events = List.generate(maps.length, (i) {
        final event = EventModel.fromMap(maps[i]);
        // Update individual event cache
        _eventCache.put(event.id, event);
        return event;
      });

      // Update cache
      _dateRangeEventsCache.put(cacheKey, events);

      return events;
    } catch (e) {
      // No debug printing
      return [];
    }
  }

  // Get a specific event by ID
  Future<EventModel?> getEventById(String id) async {
    try {
      // Check cache first
      final cachedEvent = _eventCache.get(id);
      if (cachedEvent != null) {
        // No debug printing
        return cachedEvent;
      }

      // Cache miss, query database
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'events',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        final event = EventModel.fromMap(maps.first);
        // Update cache
        _eventCache.put(id, event);
        return event;
      } else {
        return null;
      }
    } catch (e) {
      // No debug printing
      return null;
    }
  }

  // Update an event in the local database
  Future<bool> updateEvent(EventModel event) async {
    try {
      final db = await database;
      await db.update(
        'events',
        event.toMap(),
        where: 'id = ?',
        whereArgs: [event.id],
      );

      // Update cache
      _eventCache.put(event.id, event);

      // Invalidate list caches since they're now outdated
      _allEventsCache.clear();
      _dateRangeEventsCache.clear();

      return true;
    } catch (e) {
      // No debug printing
      return false;
    }
  }

  // Delete an event from the local database
  Future<bool> deleteEvent(String id) async {
    try {
      final db = await database;
      await db.delete(
        'events',
        where: 'id = ?',
        whereArgs: [id],
      );

      // Remove from cache
      _eventCache.remove(id);

      // Invalidate list caches since they're now outdated
      _allEventsCache.clear();
      _dateRangeEventsCache.clear();

      return true;
    } catch (e) {
      // No debug printing
      return false;
    }
  }

  // Search for events by title, description, or location
  Future<List<EventModel>> searchEvents(String query) async {
    try {
      // For search, we don't use cache as the query can vary widely
      // and caching all possible search results would be inefficient
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'events',
        where: 'title LIKE ? OR description LIKE ? OR location LIKE ?',
        whereArgs: ['%$query%', '%$query%', '%$query%'],
      );

      final events = List.generate(maps.length, (i) {
        final event = EventModel.fromMap(maps[i]);
        // Update individual event cache
        _eventCache.put(event.id, event);
        return event;
      });

      return events;
    } catch (e) {
      // No debug printing
      return [];
    }
  }

  // Get all events
  Future<List<EventModel>> getEvents() async {
    try {
      // Get all events from local database (this method already uses cache)
      final events = await getAllEvents();

      // Sort by start time
      events.sort((a, b) => a.startTime.compareTo(b.startTime));

      return events;
    } catch (e) {
      // No debug printing
      return [];
    }
  }

  // Get events for a specific date range
  Future<List<EventModel>> getEventsInDateRange(
      DateTime start, DateTime end) async {
    try {
      // Get events from local database (this method already uses cache)
      final events = await getEventsInRange(start, end);

      // Sort by start time
      events.sort((a, b) => a.startTime.compareTo(b.startTime));

      return events;
    } catch (e) {
      // No debug printing
      return [];
    }
  }

  // Clean expired cache entries
  void cleanCache() {
    _eventCache.cleanExpired();
    _allEventsCache.cleanExpired();
    _dateRangeEventsCache.cleanExpired();

    // No debug printing
  }
}
