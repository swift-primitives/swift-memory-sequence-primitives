# Memory Sequence Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

The contiguous → single-pass-iteration (`Sequenceable`) bridge — a thin, witness-only package supplying the default `makeIterator()` for any `Span.Protocol` conformer that opts into `Sequenceable`.

---

## Quick Start

A contiguous type — one that owns a buffer and vends a `Swift.Span` over it — becomes single-pass iterable by declaring `Sequenceable`. There is no iterator type to write: this package supplies the default `makeIterator()`, which vends the owned `Memory.Cursor` (from [swift-memory-cursor-primitives](https://github.com/swift-primitives/swift-memory-cursor-primitives)).

```swift
import Memory_Sequence_Primitives
import Span_Protocol_Primitives

// `Region` is any type that conforms to `Span.Protocol`: it owns a contiguous
// buffer and exposes a `Swift.Span` over it. Opting into single-pass iteration
// is one line — no iterator to write:
extension Region: Sequenceable {}

// `makeIterator()` now consumes the region and hands back the owned
// `Memory.Cursor` that walks its elements once, front to back.
var iterator = region.makeIterator()
while let element = iterator.next() {
    print(element)
}
```

`makeIterator()` is **consuming**: the iterator owns the consumed sequence. This is the consuming dual of [swift-memory-iterator-primitives](https://github.com/swift-primitives/swift-memory-iterator-primitives)' contiguous → `Iterable` (multipass, borrowing) bridge, and the foundation for a lazy pipeline whose stages each own the consumed stage before them.

For generic conformers whose owned `Memory.Cursor<Self>` resolves to a deeply nested type, `makeSnapshotIterator()` is the element-only alternative: it copies the contiguous elements into an owned array and vends a shallow `Memory.Snapshot.Cursor<Element>` over that copy.

Iteration is opt-in per conformer (`extension MyContiguousType: Sequenceable {}`), so it never becomes part of a contiguous type's identity — a type stays contiguous storage whether or not it iterates.

---

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-primitives/swift-memory-sequence-primitives.git", branch: "main")
]
```

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Memory Sequence Primitives", package: "swift-memory-sequence-primitives"),
    ]
)
```

---

## Architecture

One library product. The bridge is a single constrained extension; it defines no iterator of its own and re-exports the `Memory`, `Memory.Cursor`, and `Sequenceable` vocabularies it bridges.

| Product | Target | Purpose |
|---------|--------|---------|
| `Memory Sequence Primitives` | `Sources/Memory Sequence Primitives/` | The `Span.Protocol` → `Sequenceable` witness: default `makeIterator()` vending an owned `Memory.Cursor<Self>`, plus `makeSnapshotIterator()` vending an element-only `Memory.Snapshot.Cursor<Element>`. |

Foundation-free.

---

## Platform Support

| Platform | Status |
|----------|--------|
| macOS 26 | Full support |
| Linux | Full support |
| Windows | Full support |
| iOS / tvOS / watchOS / visionOS | Supported |

---

## Community

<!-- BEGIN: discussion -->
<!-- Discussion thread created at publication. -->
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
