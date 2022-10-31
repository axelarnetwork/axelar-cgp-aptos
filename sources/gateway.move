module axelar::gateway {
    use std::error;
    use aptos_std::table::{Self, Table};
    use axelar::executable_registry::{Self, ExecutableCapability};
    use aptos_std::string::String;

    const TO_EXECUTE: u8 = 0;
    const EXECUTED: u8 = 1;


    struct ContractCall has store, drop, copy {
        sourceChain: String,
        sourceAddress: String,
        destinationAddress: address,
        payloadHash: vector<u8>,
        status: u8,
    }

    struct IncomingContractCalls has key {
        table: Table<vector<u8>, ContractCall>,
    }

    /// There is no message present
    const ENO_MESSAGE: u64 = 0;

    public fun initialize_contract_calls(account: &signer) {
        move_to(account, IncomingContractCalls {
            table: table::new<vector<u8>, ContractCall>(),
        });
    }

    public fun register_executable(account: &signer): ExecutableCapability {
        executable_registry::register_executable(account)
    }

    public fun approve_contract_call(
        commandId: &vector<u8>,
        sourceChain: &String,
        sourceAddress: &String,
        destinationAddress: &address,
        payloadHash: &vector<u8>,
    ) acquires IncomingContractCalls {
        let contract_calls = borrow_global_mut<IncomingContractCalls>(@axelar);
        table::add<vector<u8>, ContractCall>(&mut contract_calls.table, *commandId, ContractCall{
            sourceChain: *sourceChain,
            sourceAddress: *sourceAddress,
            destinationAddress: *destinationAddress,
            payloadHash: *payloadHash,
            status: TO_EXECUTE,
        });
    }

    public fun validate_contract_call(
        executable: &mut ExecutableCapability,
        commandId: &vector<u8>,
    ): ContractCall acquires IncomingContractCalls {
        let contract_calls = borrow_global_mut<IncomingContractCalls>(@axelar);
        assert!(table::contains<vector<u8>, ContractCall>(&contract_calls.table, *commandId), error::not_found(ENO_MESSAGE));
        let contractCall = table::borrow_mut<vector<u8>, ContractCall>(&mut contract_calls.table, *commandId);
        assert!(contractCall.destinationAddress == executable_registry::address_of(executable), error::not_found(ENO_MESSAGE));
        assert!(contractCall.status == TO_EXECUTE, error::not_found(ENO_MESSAGE));
        contractCall.status = EXECUTED;
        *contractCall
    }



    /*#[test(account = @0x1, axelar = @axelar_gateway)]
    public entry fun sender_can_approve_contract_call(account: &signer, gateway: &signer) acquires IncomingContractCalls {
        initialize_contract_calls(gateway);
        let addr = signer::address_of(account);
        aptos_framework::account::create_account_for_test(addr);
        let commandId = keccak256(*string::bytes(&string::utf8(b"commandId")));
        let payloadHash = keccak256(*string::bytes(&string::utf8(b"commandId")));
        let destinationAddress = addr;
        let sourceChain = string::utf8(b"Ethereum");
        let sourceAddress = string::utf8(b"0x123...");
        approve_contract_call(&commandId, &sourceChain, &sourceAddress, &destinationAddress, &payloadHash);

        validate_contract_call(account, &commandId, &sourceChain, &sourceAddress, &payloadHash);
    }*/
}
