module axelar::executable_registry {
    use std::signer;

    friend axelar::gateway;

    struct ExecutableCapability has store {
        destinationAddress: address
    }

    public (friend) fun register_executable(account: &signer): ExecutableCapability {
        ExecutableCapability{ destinationAddress: signer::address_of(account) }
    }

    public fun destroy_executable(executable: ExecutableCapability) {
        ExecutableCapability {destinationAddress: _} = executable;
    }

    public fun address_of(executable: &mut ExecutableCapability): address {
        executable.destinationAddress
    }
}
