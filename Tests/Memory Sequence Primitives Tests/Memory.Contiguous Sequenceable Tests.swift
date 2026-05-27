// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-memory-sequence-primitives open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-memory-sequence-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

import Testing
import Memory_Sequence_Primitives

// A minimal owned contiguous fixture: conforms `Memory.Contiguous.Protocol`
// (owning a heap buffer it deallocates) and opts into `Sequenceable`, so the
// bridge witness supplies `makeIterator()` vending a `Memory.Cursor`.
private struct FixtureRegion: ~Copyable {
    let pointer: UnsafePointer<Int>
    let count: Int

    init(_ values: [Int]) {
        let p = UnsafeMutablePointer<Int>.allocate(capacity: values.count)
        for (i, v) in values.enumerated() { unsafe (p + i).initialize(to: v) }
        self.pointer = unsafe UnsafePointer(p)
        self.count = values.count
    }

    deinit {
        unsafe UnsafeMutablePointer(mutating: pointer).deallocate()
    }
}

extension FixtureRegion: Memory.ContiguousProtocol {
    var span: Span<Int> {
        @_lifetime(borrow self)
        borrowing get {
            let s = unsafe Span(_unsafeStart: pointer, count: count)
            return unsafe _overrideLifetime(s, borrowing: self)
        }
    }

    func withUnsafeBufferPointer<R, E: Swift.Error>(
        _ body: (UnsafeBufferPointer<Int>) throws(E) -> R
    ) throws(E) -> R {
        try unsafe body(unsafe UnsafeBufferPointer(start: pointer, count: count))
    }
}

extension FixtureRegion: Sequenceable {}

@Suite("Memory.Contiguous Sequenceable bridge")
struct MemoryContiguousSequenceableTests {
    @Test("contiguous conformer derives makeIterator and drains via the consuming pipeline")
    func iteratesContiguous() {
        var collected: [Int] = []
        var iterator = FixtureRegion([10, 20, 30, 40]).makeIterator()
        while let element = iterator.next() {
            collected.append(element)
        }

        #expect(collected == [10, 20, 30, 40])
    }

    @Test("empty contiguous conformer yields no elements")
    func iteratesEmpty() {
        var collected: [Int] = []
        var iterator = FixtureRegion([]).makeIterator()
        while let element = iterator.next() {
            collected.append(element)
        }

        #expect(collected.isEmpty)
    }
}
