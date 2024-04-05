use starknet::ContractAddress;
use starknet::class_hash::ClassHash;

#[starknet::interface]
pub trait IQuoter<TContractState> {
    // Get owner.
    //
    // # Returns
    // * `owner` - owner address
    fn owner(self: @TContractState) -> ContractAddress;

    // Get market manager.
    //
    // # Returns
    // * `market_manager` - market manager address
    fn market_manager(self: @TContractState) -> ContractAddress;

    // Obtain quote for a swap.
    //
    // # Arguments
    // * `market_id` - market ID
    // * `is_buy` - whether swap is a buy or sell
    // * `amount` - amount of tokens to swap in
    // * `exact_input` - true if `amount` is exact input, otherwise exact output
    //
    // # Returns
    // * `amount` - quoted amount out if exact input, quoted amount in if exact output
    fn quote(
        self: @TContractState, market_id: felt252, is_buy: bool, amount: u256, exact_input: bool,
    ) -> u256;

    // Obtain quotes for a list of swaps.
    // Caution: this function returns correct quotes only so long as the strategy correctly
    // reports its queued and placed positions. This function is intended for use by on-chain
    // callers that cannot retrieve `quote` via error message. Alternatively, it can be used 
    // to obtain guaranteed correct quotes for non-strategy markets.
    //
    // # Arguments
    // * `market_ids` - list of market ids
    // * `is_buy` - whether swap is a buy or sell
    // * `amount` - amount of tokens to swap in
    // * `exact_input` - true if `amount` is exact input, otherwise exact output
    //
    // # Returns
    // * `amounts` - list of quoted amounts
    fn unsafe_quote_array(
        self: @TContractState,
        market_ids: Span<felt252>,
        is_buy: bool,
        amount: u256,
        exact_input: bool
    ) -> Span<u256>;

    // Obtain quote for a multi-market swap.
    //
    // # Arguments
    // * `in_token` - in token address
    // * `out_token` - out token address
    // * `amount` - amount of tokens to swap in
    // * `route` - list of market ids defining the route to swap through
    //
    // # Returns
    // * `amount` - quoted amount out
    fn quote_multiple(
        self: @TContractState,
        in_token: ContractAddress,
        out_token: ContractAddress,
        amount: u256,
        route: Span<felt252>,
    ) -> u256;

    // Obtain quotes for a list of multi-market swaps.
    // Caution: this function returns correct quotes only so long as the strategy correctly
    // reports its queued and placed positions. This function is intended for use by on-chain
    // callers that cannot retrieve `quote` via error message. Alternatively, it can be used 
    // to obtain guaranteed correct quotes for non-strategy markets.
    //
    // # Arguments
    // * `in_token` - in token address
    // * `out_token` - out token address
    // * `amount` - amount of tokens to swap in
    // * `routes` - list of routes to swap through
    // * `route_lens` - length of each swap route
    //
    // # Returns
    // * `amounts` - list of quoted amounts
    fn unsafe_quote_multiple_array(
        self: @TContractState,
        in_token: ContractAddress,
        out_token: ContractAddress,
        amount: u256,
        routes: Span<felt252>,
        route_lens: Span<u8>,
    ) -> Span<u256>;

    // Proxies call to fetch token amounts (including accrued fees) inside a list of liquidity positions.
    // 
    // # Arguments
    // * `position_ids` - list of position ids
    //
    // # Returns
    // * `base_amount` - amount of base tokens inside position, exclusive of fees
    // * `quote_amount` - amount of quote tokens inside position, exclusive of fees
    // * `base_fees` - base fees accumulated inside position
    // * `quote_fees` - quote fees accumulated inside position
    fn amounts_inside_position_array(
        self: @TContractState,
        market_ids: Span<felt252>,
        owners: Span<felt252>,
        lower_limits: Span<u32>,
        upper_limits: Span<u32>,
    ) -> Span<(u256, u256, u256, u256)>;

    // Proxies call to fetch token amounts accrued inside a list of limit orders.
    // 
    // # Arguments
    // * `order_ids` - list of position ids
    // * `market_ids` - list of market ids
    //
    // # Returns
    // * `base_amount` - amount of base tokens inside order
    // * `quote_amount` - amount of quote tokens inside order
    fn amounts_inside_order_array(
        self: @TContractState, order_ids: Span<felt252>, market_ids: Span<felt252>
    ) -> Span<(u256, u256)>;

    // Proxies call to query token balances of a user.
    //
    // # Arguments
    // * `user` - user address
    // * `tokens` - list of token addresses
    //
    // # Returns
    // * `balances` - list of token balances
    // * `decimals` - list of token decimals
    fn token_balance_array(
        self: @TContractState, user: ContractAddress, tokens: Span<ContractAddress>
    ) -> Span<(u256, u8)>;

    // Fetch approval amounts for creating a new market.
    // 
    // # Arguments
    // * `width` - market width
    // * `start_limit` - start limit at which market is initialised
    // * `lower_limit` - lower limit of posiiton
    // * `upper_limit` - upper limit of position
    // * `liquidity_delta` - liquidity delta
    //
    // # Returns
    // * `base_amount` - amount of base tokens to approve
    // * `quote_amount` - amount of quote tokens to approve
    fn new_market_position_approval_amounts(
        self: @TContractState,
        width: u32,
        start_limit: u32,
        lower_limit: u32,
        upper_limit: u32,
        liquidity_delta: u128,
    ) -> (u256, u256);

    // Set market manager.
    //
    // # Arguments
    // * `market_manager` - market manager address
    fn set_market_manager(ref self: TContractState, market_manager: ContractAddress);

    // Upgrade contract.
    //
    // # Arguments
    // * `new_class_hash` - new class hash
    fn upgrade(ref self: TContractState, new_class_hash: ClassHash);
}
