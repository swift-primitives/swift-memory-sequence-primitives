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

public import Memory_Contiguous_Primitives
public import Memory_Cursor_Primitives
public import Sequence_Protocol_Primitives

// The contiguous → single-pass-iteration (`Sequenceable`) bridge — the
// consuming dual of swift-memory-iterator-primitives' contiguous → `Iterable`
// (multipass) bridge.
//
// `extension Memory.Contiguous.Protocol: Sequenceable` is impossible from a
// separate package (a protocol cannot gain a refinement via a retroactive
// extension), and the declaration-site form would force a sequence dependency
// onto swift-memory-primitives — refused so iteration stays out of memory's
// identity ([MOD-035]). So the pipeline capability is opt-in per conformer:
// this constrained extension supplies the default `makeIterator()` for any
// contiguous type that declares `: Sequenceable`, vending the owned
// `Memory.Cursor` over the consumed `Self`. We define no iterator of our own —
// `Memory.Cursor` (swift-memory-cursor-primitives) is the owned cursor; this
// package stays a thin witness.
//
// `Self: ~Copyable` suppresses the protocol-extension default `Self: Copyable`
// (`feedback_extension_implies_copyable` / [MEM-COPY-004]); without it the
// default would not witness the `~Copyable` `Memory.Contiguous`.
//
// `consuming` (vs the `Iterable` bridge's `borrowing`): `Sequenceable.makeIterator`
// is consuming so the iterator owns the consumed sequence — the lazy pipeline
// stores each consumed stage inside its wrapper. `Memory.Cursor` owns `Self` by
// value and re-derives the span inside each `next()`.
//
// No `@_lifetime`: `Memory.Cursor` is Escapable, and `@_lifetime` is invalid on
// an Escapable result (the Escapable witness satisfies `Sequenceable`'s
// `@_lifetime(copy self)` requirement without it — bridge-shape spike OQ-2).

extension Memory.ContiguousProtocol
where Self: Sequenceable, Self: ~Copyable, Element: Copyable & Escapable {
    @inlinable
    public consuming func makeIterator() -> Memory.Cursor<Self> {
        Memory.Cursor(self)
    }
}
