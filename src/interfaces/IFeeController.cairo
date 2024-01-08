use starknet::ContractAddress;

#[starknet::interface]
trait IFeeController<TContractState> {
    /// Returns the variable fee rate for the given contract.
    fn swap_fee_rate(self: @TContractState) -> u16;
}
