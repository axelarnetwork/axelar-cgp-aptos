module executable::executable {
    use std::signer;
    use std::string;
    use aptos_std::aptos_hash::keccak256;
    use aptos_std::string::String;
    use axelar::gateway;
    use axelar::executable_registry::ExecuteCapability;
    use aptos_framework::account;

    /// There is no message present
    const ENO_MESSAGE: u64 = 0;

    struct State has key {
        executable: ExecuteCapability,
    }

    public fun init(account: &signer) {
        let executable = gateway::register_executable(account);
        move_to(account, State { executable });
    }

    public fun execute(commandId: &vector<u8>) acquires State {
        let state = borrow_global_mut<State>(@executable);
        gateway::validate_contract_call(&mut state.executable, commandId);
    }

    public fun call_contract(
        destinationChain: String,
        destinationAddress: String,
        payload: vector<u8>,
    ) acquires State {
        let state = borrow_global_mut<State>(@executable);
        gateway::call_contract_as_contract(
            &mut state.executable,
            destinationChain,
            destinationAddress,
            payload,
        )
    }

    #[test(account = @0x1, axelar = @axelar, executable = @executable)]
    public entry fun sender_can_approve_contract_call(account: &signer, axelar: &signer, executable: &signer) acquires State {
        account::create_account_for_test(signer::address_of(axelar));
        gateway::initialize_contract_calls(axelar);
        init(executable);
        let addr = signer::address_of(account);
        aptos_framework::account::create_account_for_test(addr);
        let commandId = keccak256(*string::bytes(&string::utf8(b"commandId")));
        let payloadHash = keccak256(*string::bytes(&string::utf8(b"payloadHash")));
        let destinationAddress = @executable;
        let sourceChain = string::utf8(b"Ethereum");
        let sourceAddress = string::utf8(b"0x123...");
        gateway::approve_contract_call(&commandId, &sourceChain, &sourceAddress, &destinationAddress, &payloadHash);

        execute(&commandId);
        let commandId = keccak256(*string::bytes(&string::utf8(b"newCommandId")));
        gateway::approve_contract_call(&commandId, &sourceChain, &sourceAddress, &destinationAddress, &payloadHash);

        execute(&commandId);
    }

    #[test(account = @0x1, axelar = @axelar, executable = @executable)]
    public entry fun contract_can_call_contract(account: &signer, axelar: &signer, executable: &signer) acquires State {
        account::create_account_for_test(signer::address_of(axelar));
        gateway::initialize_contract_calls(axelar);
        init(executable);
        let addr = signer::address_of(account);
        aptos_framework::account::create_account_for_test(addr);
        let payload = *string::bytes(&string::utf8(b"payloadWithSomeRandomStuff02309434092543-103240-2"));
        let destinationAddress = string::utf8(b"destinationAddress");
        let destinationChain = string::utf8(b"Ethereum");
        
        call_contract(destinationChain, destinationAddress, payload);
    }

    #[test(account = @0x1, axelar = @axelar, executable = @executable)]
    public entry fun signer_can_call_contract(account: &signer, axelar: &signer, executable: &signer) {
        account::create_account_for_test(signer::address_of(axelar));
        gateway::initialize_contract_calls(axelar);
        init(executable);
        let addr = signer::address_of(account);
        aptos_framework::account::create_account_for_test(addr);
        let payload = *string::bytes(&string::utf8(b"payloadWithSomeRandomStuff02309434092543-103240-2"));
        let destinationAddress = string::utf8(b"destinationAddress");
        let destinationChain = string::utf8(b"Ethereum");
        
        gateway::call_contract_as_signer(
            account,
            destinationChain,
            destinationAddress,
            payload,
        )
    }
}
