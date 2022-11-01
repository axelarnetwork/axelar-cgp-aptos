module axelar::executable_registry {
    use std::signer;

    friend axelar::gateway;

    struct ExecuteCapability has store {
        address: address
    }

    public (friend) fun register_executable(account: &signer): ExecuteCapability {
        ExecuteCapability{ address: signer::address_of(account) }
    }

    public fun destroy_execute_capability(contract: ExecuteCapability) {
        ExecuteCapability {address: _} = contract;
    }

    public fun address_of(contract: &mut ExecuteCapability): address {
        contract.address
    }
}
