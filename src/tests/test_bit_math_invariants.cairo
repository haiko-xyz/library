use haiko_lib::math::math;
use haiko_lib::math::bit_math::msb;

// Checks invariants:
// 1. 2 ** msb(value) <= value
// 2. msb == 255 || 2 ** (msb(value) + 1) > value
#[test]
fn test_msb_invariant(value: u256) {
    // Handle 0 case.
    if value == 0 {
        return;
    }

    let msb = msb(value);
    let exp = math::pow(2, msb.into());

    // Invariant 1
    assert(value >= exp, 'Invariant 1');

    // Invariant 2
    if msb < 255 {
        assert(value < math::pow(2, (msb + 1).into()), 'Invariant 2');
    }
}
