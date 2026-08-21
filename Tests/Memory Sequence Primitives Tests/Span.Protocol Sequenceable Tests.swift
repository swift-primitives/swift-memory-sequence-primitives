import Memory_Sequence_Primitives
import Span_Protocol_Primitives
import Testing

private struct FixtureRegion: ~Copyable {
    let pointer: UnsafePointer<Int>
    let count: Int

    init(_ values: [Int]) {
        let p = UnsafeMutablePointer<Int>.allocate(capacity: values.count)
        for (i, v) in values.enumerated() { unsafe (p + i).initialize(to: v) }
        unsafe (self.pointer = UnsafePointer(p))
        self.count = values.count
    }

    deinit {
        unsafe UnsafeMutablePointer(mutating: pointer).deallocate()
    }
}

extension FixtureRegion: Span.`Protocol` {
    var span: Swift.Span<Int> {
        @_lifetime(borrow self)
        borrowing get {
            let s = unsafe Swift.Span(_unsafeStart: pointer, count: count)
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

@Suite
struct `Span.Protocol Sequenceable Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
}

extension `Span.Protocol Sequenceable Tests`.Unit {
    @Test
    func `iterates contiguous`() {
        var collected: [Int] = []
        var iterator = FixtureRegion([10, 20, 30, 40]).makeIterator()
        while let element = iterator.next() {
            collected.append(element)
        }

        #expect(collected == [10, 20, 30, 40])
    }
}

extension `Span.Protocol Sequenceable Tests`.`Edge Case` {
    @Test
    func `iterates empty`() {
        var collected: [Int] = []
        var iterator = FixtureRegion([]).makeIterator()
        while let element = iterator.next() {
            collected.append(element)
        }

        #expect(collected.isEmpty)
    }
}
