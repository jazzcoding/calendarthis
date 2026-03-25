import 'dart:collection';
import 'package:flutter/foundation.dart';

/// A generic cache service that can be used to cache any type of data
class CacheService<K, V> {
  /// Maximum number of items to keep in the cache
  final int maxSize;
  
  /// Time-to-live for cache entries in milliseconds
  final int ttlMs;
  
  /// The cache storage - using LinkedHashMap for LRU functionality
  final LinkedHashMap<K, _CacheEntry<V>> _cache = LinkedHashMap();
  
  /// Constructor
  CacheService({
    this.maxSize = 100,
    this.ttlMs = 300000, // 5 minutes by default
  });
  
  /// Get an item from the cache
  V? get(K key) {
    final entry = _cache[key];
    
    // If entry doesn't exist or has expired, return null
    if (entry == null || entry.isExpired()) {
      if (entry != null) {
        // Remove expired entry
        _cache.remove(key);
      }
      return null;
    }
    
    // Update access time and move to end of LinkedHashMap (most recently used)
    _cache.remove(key);
    _cache[key] = entry..updateAccessTime();
    
    return entry.value;
  }
  
  /// Put an item in the cache
  void put(K key, V value) {
    // If cache is full, remove least recently used item
    if (_cache.length >= maxSize && !_cache.containsKey(key)) {
      _cache.remove(_cache.keys.first);
    }
    
    // Add or update cache entry
    _cache[key] = _CacheEntry<V>(value, ttlMs);
    
    if (kDebugMode) {
      print('Cache: Added item with key $key. Cache size: ${_cache.length}');
    }
  }
  
  /// Remove an item from the cache
  void remove(K key) {
    _cache.remove(key);
  }
  
  /// Clear the entire cache
  void clear() {
    _cache.clear();
  }
  
  /// Get the current size of the cache
  int get size => _cache.length;
  
  /// Check if the cache contains a key
  bool containsKey(K key) {
    final entry = _cache[key];
    if (entry == null || entry.isExpired()) {
      if (entry != null) {
        // Remove expired entry
        _cache.remove(key);
      }
      return false;
    }
    return true;
  }
  
  /// Clean expired entries from the cache
  void cleanExpired() {
    final expiredKeys = <K>[];
    
    _cache.forEach((key, entry) {
      if (entry.isExpired()) {
        expiredKeys.add(key);
      }
    });
    
    for (final key in expiredKeys) {
      _cache.remove(key);
    }
    
    if (kDebugMode && expiredKeys.isNotEmpty) {
      print('Cache: Removed ${expiredKeys.length} expired entries. New size: ${_cache.length}');
    }
  }
}

/// A cache entry with value and metadata
class _CacheEntry<V> {
  /// The cached value
  final V value;
  
  /// Time-to-live in milliseconds
  final int ttlMs;
  
  /// When this entry was created
  final int _createdAt;
  
  /// When this entry was last accessed
  int _lastAccessedAt;
  
  /// Constructor
  _CacheEntry(this.value, this.ttlMs)
      : _createdAt = DateTime.now().millisecondsSinceEpoch,
        _lastAccessedAt = DateTime.now().millisecondsSinceEpoch;
  
  /// Check if this entry has expired
  bool isExpired() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return now - _createdAt > ttlMs;
  }
  
  /// Update the last access time
  void updateAccessTime() {
    _lastAccessedAt = DateTime.now().millisecondsSinceEpoch;
  }
}
