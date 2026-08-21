public import Memory_Cursor_Primitives
public import Memory_Primitive
public import Sequence_Protocol_Primitives
public import Span_Protocol_Primitives

extension Span.`Protocol`
where Self: Sequenceable, Self: ~Copyable, Element: Copyable & Escapable {

    @inlinable
    public consuming func makeIterator() -> Memory.Cursor<Self> {
        Memory.Cursor(self)
    }
}

extension Span.`Protocol`
where Self: ~Copyable, Element: Copyable & Escapable {

    @inlinable
    public consuming func makeSnapshotIterator() -> Memory.Snapshot.Cursor<Element> {
        let snapshot = span.withUnsafeBufferPointer { unsafe Array($0) }
        return Memory.Snapshot.Cursor(snapshot)
    }
}
