/// Core lib imports.
use starknet::ContractAddress;

/// Local imports.
use haiko_lib::types::core::{SwapParams, PositionInfo};

#[starknet::interface]
trait IStrategy<TContractState> {
    ////////////////////////////////
    /// VIEW
    ////////////////////////////////

    /// Get market manager contract address.
    fn market_manager(self: @TContractState) -> ContractAddress;

    /// Get strategy name.
    fn name(self: @TContractState) -> felt252;

    /// Get strategy symbol.
    fn symbol(self: @TContractState) -> felt252;

    /// Get strategy version.
    fn version(self: @TContractState) -> felt252;

    /// Get a list of positions placed by the strategy on the market.
    fn placed_positions(self: @TContractState, market_id: felt252) -> Span<PositionInfo>;

    /// Get list of positions queued to be placed by strategy on next `swap` update. If no updates
    /// are queued, the returned list will match the list returned by `placed_positions`.
    fn queued_positions(self: @TContractState, market_id: felt252) -> Span<PositionInfo>;

    ////////////////////////////////
    /// EXTERNAL
    ////////////////////////////////

    /// Called by `MarketManager` before swap to replace `placed_positions` with `queued_positions`.
    /// If the two lists are equal, no positions will be updated.
    fn update_positions(ref self: TContractState, market_id: felt252, params: SwapParams);
}
