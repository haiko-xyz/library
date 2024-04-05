use starknet::ContractAddress;

#[starknet::interface]
pub trait ILoanReceiver<TContractState> {
    // Called by `MarketManager` to pass execution context to borrower when a flash loan is taken.
    // 
    // # Arguments
    // * `token` - address of token being borrowed
    // * `amount` - amount borrowed
    // * `fee` - fee charged by `MarketManager` for the flash loan
    fn on_flash_loan(ref self: TContractState, token: ContractAddress, amount: u256, fee: u256);
}
