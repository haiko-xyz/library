////////////////////////////////
// TYPES
////////////////////////////////

#[derive(Copy, Drop, Serde, Default, storage_access::StorageAccess)]
pub struct i256 {
    pub val: u256,
    pub sign: bool
}

////////////////////////////////
// METHODS
////////////////////////////////

pub trait I256Trait {
    fn new(val: u256, sign: bool) -> i256;
    fn one() -> i256;
}

impl I256Impl of I256Trait {
    #[inline(always)]
    fn new(val: u256, sign: bool) -> i256 {
        i256 { val, sign: if val == 0 {
            false
        } else {
            sign
        } }
    }

    #[inline(always)]
    fn one() -> i256 {
        I256Trait::new(1, false)
    }
}

impl Felt252IntoI256 of Into<felt252, i256> {
    fn into(self: felt252) -> i256 {
        let abs: u256 = self.into();
        I256Trait::new(abs, false)
    }
}

impl I256PartialOrd of PartialOrd<i256> {
    #[inline(always)]
    fn le(lhs: i256, rhs: i256) -> bool {
        if rhs.sign != lhs.sign {
            lhs.sign
        } else {
            if lhs.sign {
                lhs.val >= rhs.val
            } else {
                lhs.val <= rhs.val
            }
        }
    }
    #[inline(always)]
    fn ge(lhs: i256, rhs: i256) -> bool {
        if lhs.sign != rhs.sign {
            !lhs.sign
        } else {
            if lhs.sign {
                lhs.val <= rhs.val
            } else {
                lhs.val >= rhs.val
            }
        }
    }
    #[inline(always)]
    fn lt(lhs: i256, rhs: i256) -> bool {
        if lhs.sign != rhs.sign {
            lhs.sign
        } else {
            if lhs.sign {
                lhs.val > rhs.val
            } else {
                lhs.val < rhs.val
            }
        }
    }
    #[inline(always)]
    fn gt(lhs: i256, rhs: i256) -> bool {
        if lhs.sign != rhs.sign {
            !lhs.sign
        } else {
            if lhs.sign {
                lhs.val < rhs.val
            } else {
                lhs.val > rhs.val
            }
        }
    }
}

impl I256PartialEq of PartialEq<i256> {
    #[inline(always)]
    fn eq(lhs: @i256, rhs: @i256) -> bool {
        lhs.sign == rhs.sign && lhs.val == rhs.val
    }
    #[inline(always)]
    fn ne(lhs: @i256, rhs: @i256) -> bool {
        lhs.sign != rhs.sign || lhs.val != rhs.val
    }
}

impl I256Add of Add<i256> {
    #[inline(always)]
    fn add(lhs: i256, rhs: i256) -> i256 {
        if lhs.sign == rhs.sign {
            i256 { val: lhs.val + rhs.val, sign: lhs.sign }
        } else if lhs.sign {
            if lhs.val > rhs.val {
                i256 { val: lhs.val - rhs.val, sign: true }
            } else {
                i256 { val: rhs.val - lhs.val, sign: false }
            }
        } else {
            if lhs.val >= rhs.val {
                i256 { val: lhs.val - rhs.val, sign: false }
            } else {
                i256 { val: rhs.val - lhs.val, sign: true }
            }
        }
    }
}

impl I256Sub of Sub<i256> {
    #[inline(always)]
    fn sub(lhs: i256, rhs: i256) -> i256 {
        if lhs.sign == rhs.sign {
            if lhs.val > rhs.val {
                i256 { val: lhs.val - rhs.val, sign: lhs.sign }
            } else if lhs.val < rhs.val {
                i256 { val: rhs.val - lhs.val, sign: !lhs.sign }
            } else {
                i256 { val: 0, sign: false }
            }
        } else if lhs.sign {
            i256 { val: lhs.val + rhs.val, sign: true }
        } else {
            i256 { val: lhs.val + rhs.val, sign: false }
        }
    }
}

impl I256Mul of Mul<i256> {
    #[inline(always)]
    fn mul(lhs: i256, rhs: i256) -> i256 {
        let res_sign: bool = lhs.sign ^ rhs.sign;
        let mag: u256 = lhs.val * rhs.val;
        I256Trait::new(mag, res_sign)
    }
}

impl I256Div of Div<i256> {
    #[inline(always)]
    fn div(lhs: i256, rhs: i256) -> i256 {
        let res_sign = lhs.sign ^ rhs.sign;
        let mag: u256 = lhs.val / rhs.val;
        I256Trait::new(mag, res_sign)
    }
}

impl I256Rem of Rem<i256> {
    #[inline(always)]
    fn rem(lhs: i256, rhs: i256) -> i256 {
        let res_sign = lhs.sign;
        let mag: u256 = lhs.val % rhs.val;
        I256Trait::new(mag, res_sign)
    }
}

impl I256AddEq of AddEq<i256> {
    #[inline(always)]
    fn add_eq(ref self: i256, other: i256) {
        self = I256Add::add(self, other)
    }
}

impl I256SubEq of SubEq<i256> {
    #[inline(always)]
    fn sub_eq(ref self: i256, other: i256) {
        self = I256Sub::sub(self, other)
    }
}

impl I25MulEq of MulEq<i256> {
    #[inline(always)]
    fn mul_eq(ref self: i256, other: i256) {
        self = I256Mul::mul(self, other)
    }
}

impl I256DivEq of DivEq<i256> {
    #[inline(always)]
    fn div_eq(ref self: i256, other: i256) {
        self = I256Div::div(self, other)
    }
}

impl U16IntoI256 of Into<u16, i256> {
    #[inline(always)]
    fn into(self: u16) -> i256 {
        I256Trait::new(self.into(), false)
    }
}
