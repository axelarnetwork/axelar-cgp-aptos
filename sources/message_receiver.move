module message_receiver::receive {
    use std::signer;
    use std::string::{Self, String};
    use aptos_std::aptos_hash::keccak256;
    use axelar_gateway::axelar_gateway;

    /// There is no message present
    const ENO_MESSAGE: u64 = 0;

    public fun execute(account: &signer, commandId: &vector<u8>, sourceChain: &String, sourceAddress: &String, payloadHash: &vector<u8>) {
        //let account = "module as signer here somehow".
        axelar_gateway::validate_contract_call(account, commandId, sourceChain, sourceAddress, payloadHash)
    }

    #[test(account = @0x1, gateway = @axelar_gateway, receiver = @message_receiver)]
    public entry fun sender_can_approve_contract_call(account: &signer, gateway: &signer, receiver: &signer) {
        axelar_gateway::initialize_contract_calls(gateway);
        let addr = signer::address_of(account);
        aptos_framework::account::create_account_for_test(addr);
        let commandId = keccak256(*string::bytes(&string::utf8(b"commandId")));
        let payloadHash = keccak256(*string::bytes(&string::utf8(b"commandId")));
        let destinationAddress = @message_receiver;
        let sourceChain = string::utf8(b"Ethereum");
        let sourceAddress = string::utf8(b"0x123...");
        axelar_gateway::approve_contract_call(&commandId, &sourceChain, &sourceAddress, &destinationAddress, &payloadHash);

        execute(receiver, &commandId, &sourceChain, &sourceAddress, &payloadHash);
    }
}
