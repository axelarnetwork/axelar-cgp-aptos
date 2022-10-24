module axelar_gateway::axelar_gateway {
    use std::error;
    use std::signer;
    use std::string::{Self, String};
    use aptos_std::aptos_hash::keccak256;
    use std::bcs::to_bytes;
    use aptos_std::table::{Self, Table};
    use std::vector;

    struct IncomingContractCalls has key {
        table: Table<vector<u8>, u8>,
    }

    /// There is no message present
    const ENO_MESSAGE: u64 = 0;

    public fun initialize_contract_calls(account: &signer) {
        let t = table::new<vector<u8>, u8>();
        move_to(account, IncomingContractCalls {
            table: t,
        });
    }

    public fun get_contract_call_id(commandId: &vector<u8>, sourceChain: &String, sourceAddress: &String, destinationAddress: &address, payloadHash: &vector<u8>): vector<u8> {
        let data: vector<u8> = vector::empty<u8>();
        assert!(vector::length<u8>(commandId) == 32, 0);
        assert!(vector::length<u8>(payloadHash) == 32, 1);
        vector::append<u8>(&mut data, *commandId);
        vector::append<u8>(&mut data, to_bytes<u64>(&string::length(sourceChain)));
        vector::append<u8>(&mut data, *string::bytes(sourceChain));
        vector::append<u8>(&mut data, to_bytes<u64>(&string::length(sourceAddress)));
        vector::append<u8>(&mut data, to_bytes<address>(destinationAddress));
        vector::append<u8>(&mut data, *string::bytes(sourceAddress));
        vector::append<u8>(&mut data, *payloadHash);
        keccak256(data)
    }

    public fun approve_contract_call(
        commandId: &vector<u8>,
        sourceChain: &String,
        sourceAddress: &String,
        destinationAddress: &address,
        payloadHash: &vector<u8>,
    ) acquires IncomingContractCalls {
        let id = get_contract_call_id(commandId, sourceChain, sourceAddress, destinationAddress, payloadHash);
        let contract_calls = borrow_global_mut<IncomingContractCalls>(@axelar_gateway);
        table::add<vector<u8>, u8>(&mut contract_calls.table, id, 1);
    }

    public fun validate_contract_call(
        account: &signer,
        commandId: &vector<u8>,
        sourceChain: &String,
        sourceAddress: &String,
        payloadHash: &vector<u8>,
    ) acquires IncomingContractCalls {
        let destinationAddress = signer::address_of(account);
        let id = get_contract_call_id(commandId, sourceChain, sourceAddress, &destinationAddress, payloadHash);
        let contract_calls = borrow_global_mut<IncomingContractCalls>(@axelar_gateway);
        assert!(table::contains<vector<u8>, u8>(&contract_calls.table, id), error::not_found(ENO_MESSAGE));
        table::remove<vector<u8>, u8>(&mut contract_calls.table, id);
    }



    /*#[test(account = @0x1, gateway = @axelar_gateway)]
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
