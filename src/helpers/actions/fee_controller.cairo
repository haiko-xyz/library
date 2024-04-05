// Core lib imports.
use starknet::ContractAddress;

// Haiko imports.
use haiko_lib::interfaces::IFeeController::{
    IFeeControllerDispatcher, IFeeControllerDispatcherTrait
};

// External imports.
use snforge_std::{declare, ContractClassTrait, start_prank, stop_prank, CheatTarget};

// Note: requires access to the `amm` repo.
pub fn deploy_fee_controller(swap_fee_rate: u16) -> IFeeControllerDispatcher {
    let contract = declare("FeeController");
    let contract_address = contract.deploy(@array![swap_fee_rate.into()]).unwrap();
    IFeeControllerDispatcher { contract_address }
}
