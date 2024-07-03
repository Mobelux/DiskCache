# DiskCache

DiskCache is lightweight caching libary intended to persist arbitrary data to disk.

## 📱 Requirements

Swift 5.5x toolchain with Swift Package Manager, iOS 13

## 🖥 Installation

### 📦 Swift Package Manager (recommended)

Add `DiskCache` to your `Packages.swift` file:

```swift
.package(url: "https://github.com/Mobelux/DiskCache.git", from: "2.0.0"),
```

## ⚙️ Usage

### Intialize `DiskCache` with a `StorageType`:

```swift
let cache = try DiskCache(storageType: .temporary(nil))
```

There are three storage type options, which inherently define the root directory where the cache resides:

- `temporary` - Stores data in the user's `Cache` directory. This directory is subject to the system's normal cache purging rules. Data stored here should be assumed to be ephemeral and could be purged by the system at any time.
- `permanent` - Stores data in the user's `Documents` directory. This will not be intentionally purged by the system and is safe to store long(er) term data.
- `shared` - Stores data in the app's shared container with the given `appGroupID`. This type is great for sharing data between app and extension or sibling apps.

### Cache data:

```swift
let imageData = ...
try await cache.cache(imageData, key: "cool-image")
```

### Get cached data:

```swift
var data = try await cache.data("cool-image")
```

Note: if data has not been cached with the given key, an error will be thrown. The code of this error will be `NSFileReadNoSuchFileError`

### Delete cached data:

```swift
try await cache.delete("cool-image")
```

### Delete all data:

```swift
try await cache.deleteAll()
```

## License

DiskCache is release under MIT licensing.

