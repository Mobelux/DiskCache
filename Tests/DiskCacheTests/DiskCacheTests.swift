import Foundation
import XCTest
@testable import DiskCache

final class DiskCacheTests: XCTestCase {
    static let testData = "test-data".data(using: .utf8)!
    static let cacheKey = "cache-key"

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

    func testCacheData() async throws {
        let cache = try DiskCache(storageType: .permanent(nil))
        try await cache.cache(Self.testData, key: Self.cacheKey)

        var data = try await cache.data(Self.cacheKey)

        XCTAssertEqual(data, Self.testData)

        try await cache.delete(Self.cacheKey)

        do {
            data = try await cache.data(Self.cacheKey)
            XCTFail("Expected to throw but did not")
        } catch let error as NSError {
            XCTAssertEqual(NSFileReadNoSuchFileError, error.code)
        }
    }
}
