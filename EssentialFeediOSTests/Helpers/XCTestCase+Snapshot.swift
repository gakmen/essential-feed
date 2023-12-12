//
//  XCTestCase+Snapshot.swift
//  EssentialFeediOSTests
//
//  Created by Георгий Акмен on 12.09.2023.
//

import XCTest

extension XCTestCase {
    
    func assert(snapshot: UIImage, named name: String, file: StaticString = #filePath, line: UInt = #line) {
        let snapshotData = makeSnapshotData(from: snapshot)
        let snapshotURL = makeSnapshotURL(named: name)
        
        guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
            XCTFail(
                "Failed to load snapshot from url: \(snapshotURL). Use `record` method to store a snapshot before asserting",
                file: file,
                line: line
            )
            return
        }
        
        if snapshotData != storedSnapshotData {
            let temporarySnapshotURL = URL(filePath: NSTemporaryDirectory())
                .appending(component: snapshotURL.lastPathComponent)
            try? snapshotData?.write(to: temporarySnapshotURL)
            
            XCTFail(
                "New snapshot does not match stored snapshot. New snapshot URL: \(temporarySnapshotURL). Stored snapshot URL: \(snapshotURL)",
                file: file,
                line: line
            )
        }
        
    }
    
    func record(snapshot: UIImage, named name: String, file: StaticString = #filePath, line: UInt = #line) {
        let snapshotData = makeSnapshotData(from: snapshot)
        let snapshotURL = makeSnapshotURL(named: name)
        
        do {
            try FileManager.default.createDirectory(
                at: snapshotURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try snapshotData?.write(to: snapshotURL)
            XCTFail("Record succeeded — change to 'assert' to compare the snapshots from now on.", file: file, line: line)
        } catch {
            XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
        }
    }
    
    private func makeSnapshotURL(named name: String, file: StaticString = #file) -> URL {
        let snapshotURL = URL(filePath: String(describing: file))
            .deletingLastPathComponent()
            .appending(component: "snapshots")
            .appending(component: "\(name).png")
        return snapshotURL
    }
    
    private func makeSnapshotData(from snapshot: UIImage,  file: StaticString = #file, line: UInt = #line) -> Data? {
        guard let snapshotData = snapshot.pngData() else {
            XCTFail("Failed to generate PNG data from a snapshot", file: file, line: line)
            return nil
        }
        return snapshotData
    }
}


