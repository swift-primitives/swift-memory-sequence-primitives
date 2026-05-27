# Memory Sequence Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

The contiguous → single-pass-iteration (`Sequenceable`) bridge — a thin, witness-only package supplying the default `makeIterator()` for any `Memory.Contiguous.Protocol` conformer that opts into `Sequenceable`. The vended iterator is the owned `Memory.Cursor` (from [swift-memory-cursor-primitives](https://github.com/swift-primitives/swift-memory-cursor-primitives)); this package defines no iterator of its own.

It is the **consuming** dual of [swift-memory-iterator-primitives](https://github.com/swift-primitives/swift-memory-iterator-primitives)' contiguous → `Iterable` (multipass / borrowing) bridge: `Sequenceable.makeIterator()` is `consuming`, so the iterator owns the consumed sequence — the foundation for the lazy pipeline that stores each consumed stage inside its wrapper.

Iteration is opt-in per conformer (`extension MyContiguousType: Sequenceable {}`) so it stays out of `Memory.Contiguous`'s identity (per `[MOD-035]`). Realizes part of the `Sequence.Borrowing.Protocol` retirement in `swift-institute/Research/memory-contiguous-iteration-bridge.md`.

---
