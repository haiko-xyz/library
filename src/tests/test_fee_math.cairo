// Core lib imports.
use core::integer::BoundedInt;

// Local imports.
use haiko_lib::math::fee_math::{calc_fee, gross_to_net, net_to_gross, net_to_fee, get_fee_inside};
use haiko_lib::helpers::utils::approx_eq;
use haiko_lib::types::core::{LimitInfo, Position};
use haiko_lib::types::i128::I128Trait;
use haiko_lib::types::i256::I256Trait;

////////////////////////////////
// TESTS - calc_fee
////////////////////////////////

#[test]
fn test_calc_fee() {
    let mut fee = calc_fee(0, 0);
    assert(fee == 0, 'calc_fee(0,0)');

    fee = calc_fee(1, 0);
    assert(fee == 0, 'calc_fee(1,0)');

    fee = calc_fee(0, 1);
    assert(fee == 0, 'calc_fee(0,1)');

    fee = calc_fee(1, 1000);
    assert(fee == 1, 'calc_fee(1,1000)');

    fee = calc_fee(3749, 241);
    assert(fee == 91, 'calc_fee(3749,241)');

    fee = calc_fee(100000, 100);
    assert(fee == 1000, 'calc_fee(10000,100)');

    fee = calc_fee(BoundedInt::max(), 3333);
    assert(
        fee == 38593503342797487934676209303395679687494885889057999994351212749837446108991,
        'calc_fee(MAX,3333)'
    );

    fee = calc_fee(BoundedInt::max(), 10000);
    assert(fee == BoundedInt::max(), 'calc_fee(MAX,10000)');
}

#[test]
#[should_panic(expected: ('FeeRateOF',))]
fn test_calc_fee_overflow() {
    calc_fee(50000, 10001);
}

////////////////////////////////
// TESTS - gross_to_net
////////////////////////////////

#[test]
fn test_gross_to_net() {
    let mut net = gross_to_net(0, 0);
    assert(net == 0, 'gross_to_net(0,0)');

    net = gross_to_net(5500, 0);
    assert(net == 5500, 'gross_to_net(5500,0)');

    net = gross_to_net(0, 5000);
    assert(net == 0, 'gross_to_net(0,5000)');

    net = gross_to_net(5500, 1000);
    assert(net == 4950, 'gross_to_net(5500,1000)');

    net = gross_to_net(37490, 241);
    assert(net == 36586, 'gross_to_net(37490,241)');

    net = gross_to_net(100000, 100);
    assert(net == 99000, 'gross_to_net(10000,100)');

    // Allow max deviation of 1
    net = gross_to_net(BoundedInt::max(), 3333);
    assert(
        approx_eq(
            net, 77198585894518707488894775705292228165775098776582564045106371258075683530945, 1
        ),
        'gross_to_net(MAX,3333)'
    );

    net = gross_to_net(BoundedInt::max(), 10000);
    assert(net == 0, 'gross_to_net(MAX,10000)');
}

#[test]
#[should_panic(expected: ('FeeRateOF',))]
fn test_gross_to_net_overflow() {
    gross_to_net(50000, 10001);
}

////////////////////////////////
// TESTS - net_to_gross
////////////////////////////////

#[test]
fn test_net_to_gross() {
    let mut net = net_to_gross(0, 0);
    assert(net == 0, 'net_to_gross(0,0)');

    net = net_to_gross(5500, 0);
    assert(net == 5500, 'net_to_gross(5500,0)');

    net = net_to_gross(0, 5000);
    assert(net == 0, 'net_to_gross(0,5000)');

    net = net_to_gross(5500, 1000);
    assert(net == 6111, 'net_to_gross(5500,1000)');

    net = net_to_gross(37490, 241);
    assert(net == 38415, 'net_to_gross(37490,241)');

    net = net_to_gross(100000, 100);
    assert(net == 101010, 'net_to_gross(10000,100)');

    net =
        net_to_gross(
            104212880313584575881213886507819117067942986199076507635511825607121816675942, 1000
        );
    assert(net == BoundedInt::max(), 'net_to_gross(MAX*0.9,1000)');

    net = net_to_gross(BoundedInt::max(), 0);
    assert(net == BoundedInt::max(), 'net_to_gross(MAX,0)');
}

#[test]
#[should_panic(expected: ('FeeRateOF',))]
fn test_net_to_gross_fee_rate_overflow() {
    net_to_gross(50000, 10001);
}

#[test]
#[should_panic(expected: ('MulDivOF',))]
fn test_net_to_gross_amount_overflow() {
    net_to_gross(BoundedInt::max(), 10);
}

////////////////////////////////
// TESTS - net_to_fee
////////////////////////////////

#[test]
fn test_net_to_fee() {
    let mut fee = net_to_fee(0, 0);
    assert(fee == 0, 'net_to_fee(0,0)');

    fee = net_to_fee(5500, 0);
    assert(fee == 0, 'net_to_fee(5500,0)');

    fee = net_to_fee(0, 5000);
    assert(fee == 0, 'net_to_fee(0,5000)');

    fee = net_to_fee(5500, 1000);
    assert(fee == 611, 'net_to_fee(5500,1000)');

    fee = net_to_fee(37490, 241);
    assert(fee == 925, 'net_to_fee(37490,241)');

    fee = net_to_fee(100000, 100);
    assert(fee == 1010, 'net_to_fee(10000,100)');

    fee =
        net_to_fee(
            104212880313584575881213886507819117067942986199076507635511825607121816675942, 1000
        );
    assert(
        fee == 11579208923731619542357098500868790785326998466564056403945758400791312963993,
        'net_to_fee(MAX*0.9,1000)'
    );

    fee =
        net_to_fee(
            77198585894518707488894775705292228165775098776582564045106371258075683530945, 3333
        );
    assert(
        fee == 38593503342797487934676209303395679687494885889057999994351212749837446108990,
        'net_to_fee(MAX,0)'
    );
}

#[test]
#[should_panic(expected: ('FeeRateOF',))]
fn test_net_to_fee_overflow() {
    net_to_fee(50000, 10001);
}

////////////////////////////////
// TESTS - get_fee_inside
////////////////////////////////

#[test]
fn test_get_fee_inside_cases() {
    let mut lower_limit_info = Default::default();
    let mut upper_limit_info = Default::default();

    // Position is below current price
    let (_, _, mut base_factor, mut quote_factor) = get_fee_inside(
        Default::default(), lower_limit_info, upper_limit_info, 0, 10, 15, 100, 200
    );
    assert(base_factor.val == 0 && quote_factor.val == 0, 'gfi(0,10,15,100,200)');

    // Position is above current price
    let (_, _, base_factor, quote_factor) = get_fee_inside(
        Default::default(), lower_limit_info, upper_limit_info, 5, 10, 0, 100, 200
    );
    assert(base_factor.val == 0 && quote_factor.val == 0, 'gfi(5,10,0,100,200)');

    // Position wraps current price, no fees accrued outside
    let (_, _, base_factor, quote_factor) = get_fee_inside(
        Default::default(), lower_limit_info, upper_limit_info, 0, 10, 5, 100, 200
    );
    assert(base_factor.val == 100 && quote_factor.val == 200, 'gfi(0,10,5,100,200)');

    // Position wraps current price, fees accrued above
    upper_limit_info.base_fee_factor = 25;
    upper_limit_info.quote_fee_factor = 50;
    let (_, _, base_factor, quote_factor) = get_fee_inside(
        Default::default(), lower_limit_info, upper_limit_info, 0, 10, 5, 100, 200
    );
    assert(base_factor.val == 75 && quote_factor.val == 150, 'gfi(0,10,5,100-25,200-50)');

    // Position wraps current price, fees accrued below
    upper_limit_info.base_fee_factor = 0;
    upper_limit_info.quote_fee_factor = 0;
    lower_limit_info.base_fee_factor = 12;
    lower_limit_info.quote_fee_factor = 24;
    let (_, _, base_factor, quote_factor) = get_fee_inside(
        Default::default(), lower_limit_info, upper_limit_info, 0, 10, 5, 100, 200
    );
    assert(base_factor.val == 88 && quote_factor.val == 176, 'gfi(0,10,5,100-12,200-24)');

    // Position wraps current price, fees accrued above and below
    upper_limit_info.base_fee_factor = 25;
    upper_limit_info.quote_fee_factor = 50;
    let (_, _, base_factor, quote_factor) = get_fee_inside(
        Default::default(), lower_limit_info, upper_limit_info, 0, 10, 5, 100, 200
    );
    assert(base_factor.val == 63 && quote_factor.val == 126, 'gfi(0,10,5,100-12-25,200-24-50)');
}
