// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Chat {
    mapping(string => address) public username_to_address;
    mapping(address => string) public address_to_username;

    /// username has already been taken (registered)
    error UsernameAlreadyTaken();

    /// sender has already registered a username
    error SenderAddressAlreadyRegistered();

    /// Register an unregistered username as your own
    function register(string memory username) public {
        // make sure username and address haven't been registered yet
        if (
            username_to_address[username] ==
            0x0000000000000000000000000000000000000000
        ) {
            revert UsernameAlreadyTaken();
        }
        if (bytes(address_to_username[msg.sender]).length == 0) {
            revert SenderAddressAlreadyRegistered();
        }

        username_to_address[username] = msg.sender;
        address_to_username[msg.sender] = username;
    }
}
