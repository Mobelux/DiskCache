import XCTest
@testable import DiskCache

final class DiskCacheTests: XCTestCase {
    func testTemporaryStoragePath() throws {
        let cache = try DiskCache(storageType: .temporary(.custom("temp")))
        let pathCompnents = cache.directoryURL.pathComponents

        XCTAssertEqual(pathCompnents.suffix(3), ["Caches", "com.mobelux.cache", "temp"])
    }

    func testPermanentStoragePath() throws {
        let cache = try DiskCache(storageType: .permanent(.custom("perm")))
        let pathCompnents = cache.directoryURL.pathComponents

        XCTAssertEqual(pathCompnents.suffix(3), ["Documents", "com.mobelux.cache", "perm"])
    }

    func testSharedStoragePath() throws {
        let cache = try DiskCache(storageType: .shared("app-group-id", .custom("shared")))
        let pathCompnents = cache.directoryURL.pathComponents

        XCTAssertEqual(pathCompnents.suffix(4), ["Group Containers", "app-group-id", "com.mobelux.cache", "shared"])
    }
}
