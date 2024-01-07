use traits::Into;
use integer::BoundedU256;
use debug::PrintTrait;

use haiko_lib::math::price_math::{
    shift_limit, unshift_limit, limit_to_sqrt_price, sqrt_price_to_limit, price_to_limit, max_limit,
    offset
};
use haiko_lib::constants::{
    OFFSET, MAX_LIMIT, MIN_LIMIT, MIN_SQRT_PRICE, MAX_SQRT_PRICE, MAX_WIDTH
};
use haiko_lib::types::i32::{i32, I32Trait};
use haiko_lib::tests::common::utils::{approx_eq, approx_eq_pct};

////////////////////////////////
// TESTS - shift_limit, unshift_limit
////////////////////////////////

#[test]
#[available_gas(2000000000)]
fn test_shift_limit_width_1_cases() {
    let mut limit: i32 = I32Trait::new(MIN_LIMIT, true);
    let mut width = 1;
    assert(shift_limit(limit, width) == 0, 'shift(-MAX,1)');

    limit = I32Trait::new(501234, true);
    assert(shift_limit(limit, width) == 7405391, 'shift(-501234,1)');

    limit = I32Trait::new(0, false);
    assert(shift_limit(limit, width) == OFFSET, 'shift(0,1)');

    limit = I32Trait::new(1960, false);
    assert(shift_limit(limit, width) == 7908585, 'shift(1960,1)');

    limit = I32Trait::new(MAX_LIMIT, false);
    assert(shift_limit(limit, width) == 15813250, 'shift(MAX,1)');
}

#[test]
#[available_gas(2000000000)]
fn test_shift_limit_width_gt_1_cases() {
    let mut limit: i32 = I32Trait::new(7906620, true);
    let mut width = 10;
    assert(shift_limit(limit, width) == 0, 'shift(-7906620,10)');

    limit = I32Trait::new(501230, false);
    assert(shift_limit(limit, width) == 8407850, 'shift(501230,10)');

    limit = I32Trait::new(1650000, true);
    width = 33; // offset = 7906602
    assert(shift_limit(limit, width) == 6256602, 'shift(-1650000,33)');

    limit = I32Trait::new(0, false);
    assert(shift_limit(limit, width) == 7906602, 'shift(0,33)');
}

#[test]
#[should_panic(expected: ('ShiftLimitUnderflow',))]
#[available_gas(2000000000)]
fn test_shift_limit_cases_underflow() {
    let limit: i32 = I32Trait::new(OFFSET + 1, true);
    let width = 10;
    shift_limit(limit, width);
}

#[test]
#[should_panic(expected: ('ShiftLimitOF',))]
#[available_gas(2000000000)]
fn test_shift_limit_cases_overflow() {
    let limit: i32 = I32Trait::new(MAX_LIMIT + 1, false);
    let width = 1;
    shift_limit(limit, width);
}

#[test]
#[available_gas(2000000000)]
fn test_unshift_limit_width_1_cases() {
    let mut limit: u32 = OFFSET + 1;
    let mut width = 1;
    assert(unshift_limit(limit, width) == I32Trait::new(1, false), 'unshift(OFFSET+1,1)');

    limit = 0;
    assert(unshift_limit(limit, width) == I32Trait::new(OFFSET, true), 'unshift(0,1)');

    limit = 1960;
    assert(unshift_limit(limit, width) == I32Trait::new(7904665, true), 'unshift(1960,1)');

    limit = 501234;
    assert(unshift_limit(limit, width) == I32Trait::new(7405391, true), 'unshift(501234,1)');

    limit = OFFSET + MAX_LIMIT;
    assert(unshift_limit(limit, width) == I32Trait::new(MAX_LIMIT, false), 'unshift(OFFSET+MAX,1)');
}

#[test]
#[available_gas(2000000000)]
fn test_unshift_limit_width_gt_1_cases() {
    let mut limit: u32 = 0;
    let mut width = 10;
    assert(unshift_limit(limit, width) == I32Trait::new(7906620, true), 'unshift(0,10)');

    limit = 9373560;
    assert(unshift_limit(limit, width) == I32Trait::new(1466940, false), 'unshift(9373560,10)');

    limit = 2887335;
    width = 45; // offset = 7906590
    assert(unshift_limit(limit, width) == I32Trait::new(5019255, true), 'unshift(-2887335,45)');

    limit = 7906590;
    assert(unshift_limit(limit, width) == I32Trait::new(0, false), 'unshift(7906590,45)');
}

////////////////////////////////
// TESTS - limit_to_sqrt_price
////////////////////////////////

#[test]
#[available_gas(2000000000)]
fn test_limit_to_sqrt_price_width_1_cases() {
    let mut limit: u32 = OFFSET - MIN_LIMIT;
    let width = 1;
    assert(limit_to_sqrt_price(limit, width) == MIN_SQRT_PRICE, 'l->p MIN');

    limit = OFFSET - MIN_LIMIT + 1;
    assert(approx_eq(limit_to_sqrt_price(limit, width), 67775070201, 1), 'l->p MIN+1');

    limit = OFFSET - 1150000;
    assert(limit_to_sqrt_price(limit, width) == 31828723021629170035251312, 'l->p -1150000');

    limit = OFFSET - 950000;
    assert(limit_to_sqrt_price(limit, width) == 86519006819519020213519911, 'l->p -950000');

    limit = OFFSET - 250000;
    assert(limit_to_sqrt_price(limit, width) == 2865065875088286000374254002, 'l->p -250000');

    limit = OFFSET - 47500;
    assert(limit_to_sqrt_price(limit, width) == 7885978274341976831474794041, 'l->p -47500');

    limit = OFFSET - 22484;
    assert(limit_to_sqrt_price(limit, width) == 8936693400839181505195305981, 'l->p -22484');

    limit = OFFSET - 9999;
    assert(limit_to_sqrt_price(limit, width) == 9512344184429357105567813281, 'l->p -9999');

    limit = OFFSET - 1872;
    assert(limit_to_sqrt_price(limit, width) == 9906837148119240093576097895, 'l->p -1872');

    limit = OFFSET - 396;
    assert(limit_to_sqrt_price(limit, width) == 9980219687872597169568506614, 'l->p -396');

    limit = OFFSET - 50;
    assert(limit_to_sqrt_price(limit, width) == 9997500324970752047381250938, 'l->p -50');

    limit = OFFSET - 1;
    assert(limit_to_sqrt_price(limit, width) == 9999950000374996875027343504, 'l->p -1');

    limit = OFFSET;
    assert(limit_to_sqrt_price(limit, width) == 10000000000000000000000000000, 'l->p 0');

    limit = OFFSET + 1;
    assert(limit_to_sqrt_price(limit, width) == 10000049999875000624996093778, 'l->p 1');

    limit = OFFSET + 25;
    assert(limit_to_sqrt_price(limit, width) == 10001250071877515684747109447, 'l->p 25');

    limit = OFFSET + 450;
    assert(limit_to_sqrt_price(limit, width) == 10022525218742400856832334477, 'l->p 450');

    limit = OFFSET + 2719;
    assert(limit_to_sqrt_price(limit, width) == 10136877633151767879083939822, 'l->p 2719');

    limit = OFFSET + 14999;
    assert(limit_to_sqrt_price(limit, width) == 10778783573025323312733842362, 'l->p 14999');

    limit = OFFSET + 55000;
    assert(limit_to_sqrt_price(limit, width) == 13165288646512563030484384832, 'l->p 55000');

    limit = OFFSET + 249000;
    assert(limit_to_sqrt_price(limit, width) == 34729131805291136927238747986, 'l->p 249000');

    limit = OFFSET + 888000;
    assert(limit_to_sqrt_price(limit, width) == 847730597035592474894705542056, 'l->p 888000');

    limit = OFFSET + 1350000;
    assert(limit_to_sqrt_price(limit, width) == 8540299387214792726855084583850, 'l->p 1350000');

    limit = OFFSET + 4500000;
    assert(
        approx_eq_pct(
            limit_to_sqrt_price(limit, width), 59098571711246800030041333323272877718, 20
        ),
        'l->p 4500000'
    );

    limit = OFFSET + 5500000;
    assert(
        approx_eq_pct(
            limit_to_sqrt_price(limit, width), 8770786455175854494079784255897072914655, 8
        ),
        'l->p 5500000'
    );

    limit = OFFSET + 6500000;
    assert(
        approx_eq_pct(
            limit_to_sqrt_price(limit, width), 1301667583747318151082988967463051234466449, 8
        ),
        'l->p 6500000'
    );

    limit = OFFSET + 7500000;
    assert(
        approx_eq_pct(
            limit_to_sqrt_price(limit, width), 193179768682968120670626619759297849997312135, 8
        ),
        'l->p 7500000'
    );

    limit = OFFSET + MAX_LIMIT - 1;
    assert(
        approx_eq_pct(
            limit_to_sqrt_price(limit, width), 1475468777891786697833509843618285689088340037, 8
        ),
        'l->p MAX-1'
    );

    limit = OFFSET + MAX_LIMIT;
    assert(approx_eq_pct(limit_to_sqrt_price(limit, width), MAX_SQRT_PRICE, 20), 'l->p MAX');
}

#[test]
#[available_gas(2000000000)]
fn test_limit_to_sqrt_price_width_gt_1_cases() {
    let mut width = 20;
    let mut limit: u32 = offset(width) - 7906620;
    assert(limit_to_sqrt_price(limit, width) == 67776425709, 'l->p MIN,20');

    width = 2;
    limit = offset(width) - 250000;
    assert(limit_to_sqrt_price(limit, width) == 2865065875088286000374254002, 'l->p -250000,2');

    width = 5;
    limit = offset(width) - 50;
    assert(limit_to_sqrt_price(limit, width) == 9997500324970752047381250938, 'l->p -50,5');

    width = 24;
    limit = offset(width) - 1;
    assert(limit_to_sqrt_price(limit, width) == 9999950000374996875027343504, 'l->p -1,24');

    width = 5500;
    limit = offset(width) - 0;
    assert(limit_to_sqrt_price(limit, width) == 10000000000000000000000000000, 'l->p 0,5500');

    width = 10000;
    limit = offset(width) + 1;
    assert(limit_to_sqrt_price(limit, width) == 10000049999875000624996093778, 'l->p 1,10000');

    width = 4;
    limit = offset(width) + 55000;
    assert(limit_to_sqrt_price(limit, width) == 13165288646512563030484384832, 'l->p 55000,4');

    width = 25;
    limit = offset(width) + 7906625;
    assert(
        approx_eq_pct(
            limit_to_sqrt_price(limit, width), 1475476155217232889259573944724344224035633065, 8
        ),
        'l->p MAX,25'
    );
}

#[test]
#[should_panic(expected: ('LimitOF',))]
#[available_gas(2000000000)]
fn test_limit_to_sqrt_price_limit_overflow() {
    let limit: u32 = OFFSET + MAX_LIMIT + 1;
    let width = 1;
    limit_to_sqrt_price(limit, width);
}

#[test]
#[should_panic(expected: ('WidthOF',))]
#[available_gas(2000000000)]
fn test_limit_to_sqrt_price_width_overflow() {
    let limit: u32 = OFFSET + 10000;
    let width = MAX_WIDTH + 1;
    limit_to_sqrt_price(limit, width);
}

////////////////////////////////
// TESTS - sqrt_price_to_limit
////////////////////////////////

#[test]
#[available_gas(2000000000)]
fn test_sqrt_price_to_limit_width_1_cases() {
    let mut sqrt_price: u256 = MIN_SQRT_PRICE;
    let width = 1;
    assert(sqrt_price_to_limit(sqrt_price, width) == OFFSET - MIN_LIMIT, 'p->l MIN');

    sqrt_price = 67775070201;
    assert((OFFSET - 7906624) - sqrt_price_to_limit(sqrt_price, width) <= 1, 'p->l MIN+1');

    sqrt_price = 31828723021629170035251312;
    assert((OFFSET - 1150000) - sqrt_price_to_limit(sqrt_price, width) <= 1, 'p->l -1150000');

    sqrt_price = 86519006819519020213519911;
    assert((OFFSET - 950000) - sqrt_price_to_limit(sqrt_price, width) <= 1, 'p->l -950000');

    sqrt_price = 2865065875088286000374254002;
    assert((OFFSET - 250000) - sqrt_price_to_limit(sqrt_price, width) <= 1, 'p->l -250000');

    sqrt_price = 7885978274341976831474794041;
    assert((OFFSET - 47500) - sqrt_price_to_limit(sqrt_price, width) <= 1, 'p->l -47500');

    sqrt_price = 8936693400839181505195305981;
    assert((OFFSET - 22484) - sqrt_price_to_limit(sqrt_price, width) <= 1, 'p->l -22484');

    sqrt_price = 9512344184429357105567813281;
    assert((OFFSET - 9999) - sqrt_price_to_limit(sqrt_price, width) <= 1, 'p->l -9999');

    sqrt_price = 9906837148119240093576097895;
    assert((OFFSET - 1872) - sqrt_price_to_limit(sqrt_price, width) <= 1, 'p->l -1872');

    sqrt_price = 9980219687872597169568506614;
    assert((OFFSET - 396) - sqrt_price_to_limit(sqrt_price, width) <= 1, 'p->l -396');

    sqrt_price = 9997500324970752047381250938;
    assert((OFFSET - 50) - sqrt_price_to_limit(sqrt_price, width) <= 1, 'p->l -50');

    sqrt_price = 9999950000374996875027343504;
    assert((OFFSET - 1) - sqrt_price_to_limit(sqrt_price, width) <= 1, 'p->l -1');

    sqrt_price = 10000000000000000000000000000;
    assert(sqrt_price_to_limit(sqrt_price, width) == OFFSET, 'p->l 0');

    sqrt_price = 10000049999875000624996093778;
    assert((OFFSET + 1) - sqrt_price_to_limit(sqrt_price, width) <= 1, 'p->l 1');

    sqrt_price = 10001250071877515684747109447;
    assert((OFFSET + 25) - sqrt_price_to_limit(sqrt_price, width) <= 1, 'p->l 25');

    sqrt_price = 10022525218742400856832334477;
    assert(sqrt_price_to_limit(sqrt_price, width) == OFFSET + 450, 'p->l 450');

    sqrt_price = 10136877633151767879083939822;
    assert(sqrt_price_to_limit(sqrt_price, width) == OFFSET + 2719, 'p->l 2719');

    sqrt_price = 10778783573025323312733842362;
    assert(sqrt_price_to_limit(sqrt_price, width) == OFFSET + 14999, 'p->l 14999');

    sqrt_price = 13165288646512563030484384832;
    assert(sqrt_price_to_limit(sqrt_price, width) == OFFSET + 55000, 'p->l 55000');

    sqrt_price = 34729131805291136927238747986;
    assert(sqrt_price_to_limit(sqrt_price, width) == OFFSET + 249000, 'p->l 249000');

    sqrt_price = 847730597035592474894705542056;
    assert(sqrt_price_to_limit(sqrt_price, width) == OFFSET + 888000, 'p->l 888000');

    sqrt_price = 8540299387214792726855084583850;
    assert(sqrt_price_to_limit(sqrt_price, width) == OFFSET + 1350000, 'p->l 1350000');

    sqrt_price = 59098571711246800030041333323272877718;
    assert(
        approx_eq_pct(sqrt_price_to_limit(sqrt_price, width).into(), OFFSET.into() + 4500000, 20),
        'p->l 4500000'
    );

    sqrt_price = 8770786455175854494079784255897072914655;
    assert(
        approx_eq_pct(sqrt_price_to_limit(sqrt_price, width).into(), OFFSET.into() + 5500000, 20),
        'p->l 5500000'
    );

    sqrt_price = 1301667583747318151082988967463051234466449;
    assert(
        approx_eq_pct(sqrt_price_to_limit(sqrt_price, width).into(), OFFSET.into() + 6500000, 20),
        'p->l 6500000'
    );

    sqrt_price = 193179768682968120670626619759297849997312135;
    assert(
        approx_eq_pct(sqrt_price_to_limit(sqrt_price, width).into(), OFFSET.into() + 7500000, 20),
        'p->l 7500000'
    );

    sqrt_price = 1475468777891786697833509843618285689088340037;
    assert(
        approx_eq_pct(
            sqrt_price_to_limit(sqrt_price, width).into(), (OFFSET + MAX_LIMIT - 1).into(), 8
        ),
        'p->l MAX-1'
    );

    sqrt_price = MAX_SQRT_PRICE;
    assert(sqrt_price_to_limit(sqrt_price, width) == OFFSET + MAX_LIMIT, 'p->l MAX');
}

#[test]
#[available_gas(2000000000)]
fn test_sqrt_price_to_limit_width_gt_1_cases() {
    let mut sqrt_price: u256 = 67776425709;
    let mut width = 20;
    assert(sqrt_price_to_limit(sqrt_price, width) == offset(width) - 7906620, 'p->l MIN, 20');

    sqrt_price = 2865065875088286000374254002;
    width = 2;
    assert(offset(width) - 250000 - sqrt_price_to_limit(sqrt_price, width) <= 1, 'p->l -250000,2');

    sqrt_price = 9997500324970752047381250938;
    width = 5;
    assert(offset(width) - 50 - sqrt_price_to_limit(sqrt_price, width) <= 1, 'p->l -50,5');

    sqrt_price = 9999950000374996875027343504;
    width = 24;
    assert(offset(width) - 1 - sqrt_price_to_limit(sqrt_price, width) <= 1, 'p->l -1,24');

    sqrt_price = 10000000000000000000000000000;
    width = 5500;
    assert(sqrt_price_to_limit(sqrt_price, width) == offset(width) - 0, 'p->l 0,5500');

    sqrt_price = 10000049999875000624996093778;
    width = 10000;
    assert(sqrt_price_to_limit(sqrt_price, width) == offset(width) + 0, 'p->l 1,10000');

    sqrt_price = 13165288646512563030484384832;
    width = 4;
    assert(sqrt_price_to_limit(sqrt_price, width) == offset(width) + 55000, 'p->l 55000,4');

    sqrt_price = 847730597035592474894705542056;
    width = 10;
    assert(sqrt_price_to_limit(sqrt_price, width) == offset(width) + 888000, 'p->l 888000,10');

    sqrt_price = 1475468777891786697833509843618285689088340037;
    width = 25;
    assert(
        approx_eq_pct(
            sqrt_price_to_limit(sqrt_price, width).into(),
            (offset(width) + MAX_LIMIT - 1).into(),
            20
        ),
        'p->l MAX-1,25'
    );

    sqrt_price = 1475291733146559100490057806901054223599512637;
    width = 40;
    assert(sqrt_price_to_limit(sqrt_price, width) == offset(width) + 7906600, 'p->l MAX,40');
}

#[test]
#[should_panic(expected: ('SqrtPriceOF',))]
#[available_gas(2000000000)]
fn test_sqrt_price_to_limit_underflow() {
    let sqrt_price: u256 = MIN_SQRT_PRICE - 1;
    let width = 1;
    sqrt_price_to_limit(sqrt_price, width);
}

#[test]
#[should_panic(expected: ('SqrtPriceOF',))]
#[available_gas(2000000000)]
fn test_sqrt_price_to_limit_overflow() {
    let sqrt_price: u256 = MAX_SQRT_PRICE + 1;
    let width = 1;
    sqrt_price_to_limit(sqrt_price, width);
}

////////////////////////////////
// TESTS - price_to_limit
////////////////////////////////

#[test]
#[available_gas(2000000000)]
fn test_price_to_limit() {
    let mut price: u256 = 1;
    let mut width = 1;
    assert(1459355 - price_to_limit(price, width, false) <= 1, 'P->l(1,1)');

    price = 823185190241736438;
    width = 4;
    assert(5584570 - price_to_limit(price, width, false) <= 1, 'P->l(8231,4)');

    price = 9999950000374996875027343504;
    width = 20;
    assert(7906620 - price_to_limit(price, width, false) <= 1, 'P->l(9999,20)');

    price = 10000000000000000000000000000;
    width = 100;
    assert(7906600 - price_to_limit(price, width, false) <= 1, 'P->l(1000,100)');

    price = 4873111937056930770242496363471129837;
    width = 66;
    assert(9907053 - price_to_limit(price, width, false) <= 1, 'P->l(4873,66)');

    price = 1647812259929876135679834711867148424422577661217622160914;
    width = 25;
    assert(14634100 - price_to_limit(price, width, false) <= 1, 'P->l(16478,25)');
}
