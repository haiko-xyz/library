// Core lib imports.
use starknet::ContractAddress;

// Haiko imports.
use haiko_lib::interfaces::IQuoter::{IQuoter, IQuoterDispatcher, IQuoterDispatcherTrait};

// External imports.
use snforge_std::{declare, ContractClassTrait};

// Note: requires access to the `amm` repo.
pub fn deploy_quoter(owner: ContractAddress, market_manager: ContractAddress) -> IQuoterDispatcher {
    let contract = declare("Quoter");
    let contract_address = contract.deploy(@array![owner.into(), market_manager.into()]).unwrap();
    IQuoterDispatcher { contract_address }
}
