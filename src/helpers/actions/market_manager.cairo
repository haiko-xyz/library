// Core lib imports.
use core::result::ResultTrait;
use starknet::ContractAddress;
use starknet::contract_address_const;

// Haiko imports.
use haiko_lib::math::price_math;
use haiko_lib::id;
use haiko_lib::interfaces::IMarketManager::{
    IMarketManagerDispatcher, IMarketManagerDispatcherTrait
};
use haiko_lib::types::core::MarketInfo;
use haiko_lib::types::i256::i256;
use haiko_lib::helpers::params::{
    CreateMarketParams, ModifyPositionParams, SwapParams, SwapMultipleParams, TransferOwnerParams
};

// External imports.
use snforge_std::{declare, ContractClass, ContractClassTrait, start_prank, stop_prank, CheatTarget};
use openzeppelin::token::erc20::interface::{ERC20ABIDispatcher, ERC20ABIDispatcherTrait};

// Note: requires access to the `amm` repo.
pub fn deploy_market_manager(
    class: ContractClass, owner: ContractAddress,
) -> IMarketManagerDispatcher {
    let contract_address = class
        .deploy(@array![owner.into(), 'Haiko Liquidity Positions', 'HAIKO-LP'])
        .unwrap();
    IMarketManagerDispatcher { contract_address }
}

pub fn create_market(
    market_manager: IMarketManagerDispatcher, params: CreateMarketParams
) -> felt252 {
    start_prank(CheatTarget::One(market_manager.contract_address), params.owner);
    let market_id = id::market_id(
        MarketInfo {
            base_token: params.base_token,
            quote_token: params.quote_token,
            strategy: params.strategy,
            width: params.width,
            swap_fee_rate: params.swap_fee_rate,
            fee_controller: params.fee_controller,
            controller: params.controller,
        }
    );
    let whitelisted = market_manager.is_market_whitelisted(market_id);
    if (params.strategy != contract_address_const::<0x0>()
        || params.fee_controller != contract_address_const::<0x0>()
        || params.controller != contract_address_const::<0x0>())
        && !whitelisted {
        market_manager.whitelist_markets(array![market_id]);
    }
    let market_id = market_manager
        .create_market(
            params.base_token,
            params.quote_token,
            params.width,
            params.strategy,
            params.swap_fee_rate,
            params.fee_controller,
            params.start_limit,
            params.controller,
            params.market_configs,
        );
    stop_prank(CheatTarget::One(market_manager.contract_address));
    market_id
}

pub fn create_market_without_whitelisting(
    market_manager: IMarketManagerDispatcher, params: CreateMarketParams
) -> felt252 {
    start_prank(CheatTarget::One(market_manager.contract_address), params.owner);
    market_manager
        .create_market(
            params.base_token,
            params.quote_token,
            params.width,
            params.strategy,
            params.swap_fee_rate,
            params.fee_controller,
            params.start_limit,
            params.controller,
            params.market_configs,
        )
}

pub fn modify_position(
    market_manager: IMarketManagerDispatcher, params: ModifyPositionParams,
) -> (i256, i256, u256, u256) {
    start_prank(CheatTarget::One(market_manager.contract_address), params.owner);
    let (base_amount, quote_amount, base_fees, quote_fees) = market_manager
        .modify_position(
            params.market_id, params.lower_limit, params.upper_limit, params.liquidity_delta,
        );
    stop_prank(CheatTarget::One(market_manager.contract_address));

    (base_amount, quote_amount, base_fees, quote_fees)
}

pub fn swap(market_manager: IMarketManagerDispatcher, params: SwapParams) -> (u256, u256, u256) {
    start_prank(CheatTarget::One(market_manager.contract_address), params.owner);
    let (amount_in, amount_out, fees) = market_manager
        .swap(
            params.market_id,
            params.is_buy,
            params.amount,
            params.exact_input,
            params.threshold_sqrt_price,
            params.threshold_amount,
            params.deadline,
        );
    stop_prank(CheatTarget::One(market_manager.contract_address));
    (amount_in, amount_out, fees)
}

pub fn swap_multiple(market_manager: IMarketManagerDispatcher, params: SwapMultipleParams) -> u256 {
    start_prank(CheatTarget::One(market_manager.contract_address), params.owner);
    let amount_out = market_manager
        .swap_multiple(
            params.in_token,
            params.out_token,
            params.amount,
            params.route,
            params.threshold_amount,
            params.deadline,
        );
    stop_prank(CheatTarget::One(market_manager.contract_address));
    amount_out
}

pub fn transfer_owner(market_manager: IMarketManagerDispatcher, params: TransferOwnerParams) -> () {
    start_prank(CheatTarget::One(market_manager.contract_address), params.owner);
    market_manager.transfer_owner(params.new_owner);
}

pub fn accept_owner(market_manager: IMarketManagerDispatcher, new_owner: ContractAddress) -> () {
    start_prank(CheatTarget::One(market_manager.contract_address), new_owner);
    market_manager.accept_owner();
}
