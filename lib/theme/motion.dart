/// Duration for a piece sliding to a new square, and for effects kept in
/// lockstep with that slide — the capture fade-out, the lift shadow
/// settling back down. One shared constant instead of the same magic
/// number repeated across widgets, so they can never drift out of sync.
const pieceMoveDuration = Duration(milliseconds: 380);
