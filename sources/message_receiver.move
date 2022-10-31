module message_receiver::receive {
    use std::signer;
    use std::string;
    use aptos_std::aptos_hash::keccak256;
    use axelar::gateway;
    use axelar::executable_registry::ExecutableCapability;

    /// There is no message present
    const ENO_MESSAGE: u64 = 0;

    struct State has key {
        executable: ExecutableCapability,
    }

    public fun init(account: &signer) {
        let executable = gateway::register_executable(account);
        move_to(account, State { executable });
    }

    public fun execute(commandId: &vector<u8>) acquires State {
        let state = borrow_global_mut<State>(@message_receiver);
        gateway::validate_contract_call(&mut state.executable, commandId);
    }

    #[test(account = @0x1, axelar = @axelar, receiver = @message_receiver)]
    public entry fun sender_can_approve_contract_call(account: &signer, axelar: &signer, receiver: &signer) acquires State {
        gateway::initialize_contract_calls(axelar);
        init(receiver);
        let addr = signer::address_of(account);
        aptos_framework::account::create_account_for_test(addr);
        let commandId = keccak256(*string::bytes(&string::utf8(b"commandId")));
        let payloadHash = keccak256(*string::bytes(&string::utf8(b"payloadHash")));
        let destinationAddress = @message_receiver;
        let sourceChain = string::utf8(b"Ethereum");
        let sourceAddress = string::utf8(b"0x123...");
        gateway::approve_contract_call(&commandId, &sourceChain, &sourceAddress, &destinationAddress, &payloadHash);

        execute(&commandId);
        let commandId = keccak256(*string::bytes(&string::utf8(b"newCommandId")));
        gateway::approve_contract_call(&commandId, &sourceChain, &sourceAddress, &destinationAddress, &payloadHash);

        execute(&commandId);
    }
}
