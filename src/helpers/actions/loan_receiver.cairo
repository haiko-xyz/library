// Core lib imports.
use starknet::ContractAddress;

// Local imports.
use haiko_lib::interfaces::ILoanReceiver::{ILoanReceiverDispatcher, ILoanReceiverDispatcherTrait};

// External imports.
use snforge_std::{declare, ContractClassTrait, start_prank, stop_prank, CheatTarget};

pub fn deploy_loan_receiver(market_manager: ContractAddress) -> ILoanReceiverDispatcher {
    let contract = declare("LoanReceiver");
    let contract_address = contract.deploy(@array![market_manager.into()]).unwrap();
    ILoanReceiverDispatcher { contract_address }
}
