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

public import Memory_Cursor_Primitives
public import Memory_Primitive
public import Sequence_Protocol_Primitives
public import Span_Protocol_Primitives

// The contiguous → single-pass-iteration (`Sequenceable`) bridge — the
// consuming dual of swift-memory-iterator-primitives' contiguous → `Iterable`
// (multipass) bridge.
//
// `extension Span.\`Protocol\`: Sequenceable` is impossible from a separate
// package (a protocol cannot gain a refinement via a retroactive extension),
// and the declaration-site form would force a sequence dependency onto
// swift-span-primitives — refused so iteration stays out of the span
// capability's identity ([MOD-035]). So the pipeline capability is opt-in per conformer:
// this constrained extension supplies the default `makeIterator()` for any
// contiguous type that declares `: Sequenceable`, vending the owned
// `Memory.Cursor` over the consumed `Self`. We define no iterator of our own —
// `Memory.Cursor` (swift-memory-cursor-primitives) is the owned cursor; this
// package stays a thin witness.
//
// `Self: ~Copyable` suppresses the protocol-extension default `Self: Copyable`
// (`feedback_extension_implies_copyable` / [MEM-COPY-004]); without it the
// default would not witness `~Copyable` owned contiguous conformers (e.g.
// `Storage.Contiguous` over a heap allocation).
//
// `consuming` (vs the `Iterable` bridge's `borrowing`): `Sequenceable.makeIterator`
// is consuming so the iterator owns the consumed sequence — the lazy pipeline
// stores each consumed stage inside its wrapper. `Memory.Cursor` owns `Self` by
// value and re-derives the span inside each `next()`.
//
// No `@_lifetime`: `Memory.Cursor` is Escapable, and `@_lifetime` is invalid on
// an Escapable result (the Escapable witness satisfies `Sequenceable`'s
// `@_lifetime(copy self)` requirement without it — bridge-shape spike OQ-2).

extension Span.`Protocol`
where Self: Sequenceable, Self: ~Copyable, Element: Copyable & Escapable {
    /// Consumes this contiguous sequence and vends the owned `Memory.Cursor` that single-pass-iterates its elements.
    @inlinable
    public consuming func makeIterator() -> Memory.Cursor<Self> {
        Memory.Cursor(self)
    }
}

// RESHAPE (issue-investigation, demangle dodge): an alternative bridge vending the
// ELEMENT-only-generic `Memory.Snapshot.Cursor<Element>` instead of `Memory.Cursor<Self>`. The
// `Sequenceable.Iterator` associated-type witness for a generic conformer is then the SHALLOW
// `Memory.Snapshot.Cursor<A>`, never the deeply-nested `Memory.Cursor<Buffer<Storage<A>.Contiguous<Memory.Heap<A>>>.Linear.Inline<8>>`
// whose mangled name IRGen corrupts (runtime demangle '}' in debug; LLVM broken-module in release).
// Snapshots the contiguous span into an owned `[Element]` (source is already contiguous in memory;
// `Element: Copyable`). VALIDATED against the literal Buffer.Linear.Inline topology in
// `Experiments/memory-cursor-generic-witness-demangle` (target F).
extension Span.`Protocol`
where Self: ~Copyable, Element: Copyable & Escapable {
    /// Consumes this contiguous sequence and vends an element-only `Memory.Snapshot.Cursor` over an owned copy of its elements.
    @inlinable
    public consuming func makeSnapshotIterator() -> Memory.Snapshot.Cursor<Element> {
        let snapshot = span.withUnsafeBufferPointer { Array($0) }
        return Memory.Snapshot.Cursor(snapshot)
    }
}
