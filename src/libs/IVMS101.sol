// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library IVMS101 {
    struct Party {
        string name;
        string accountNumber;
        string country;
        string idType;
        string idValue;
    }

    struct Message {
        Party originator;
        Party beneficiary;
        string sendingVASP;
        string receivingVASP;
        string txReference;
        string purpose;
        string extraURI;
    }

    function hash(Message memory m) internal pure returns (bytes32) {
        return keccak256(abi.encode(
            _hashParty(m.originator),
            _hashParty(m.beneficiary),
            keccak256(bytes(m.sendingVASP)),
            keccak256(bytes(m.receivingVASP)),
            keccak256(bytes(m.txReference)),
            keccak256(bytes(m.purpose)),
            keccak256(bytes(m.extraURI))
        ));
    }

    function _hashParty(Party memory p) private pure returns (bytes32) {
        return keccak256(abi.encode(
            keccak256(bytes(p.name)),
            keccak256(bytes(p.accountNumber)),
            keccak256(bytes(p.country)),
            keccak256(bytes(p.idType)),
            keccak256(bytes(p.idValue))
        ));
    }
}
