// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Chat {
    mapping(string => address) public username_to_address;
    mapping(address => string) public address_to_username;

    /// sender's address does not match registered username's owner
    error NotUsernameOwner();

    /// username has already been taken (registered)
    error UsernameAlreadyTaken();

    /// sender has already registered a username
    error SenderAddressAlreadyRegistered();

    /// username must be at least than 3 characters
    error UsernameFewerThan3Characters();

    /// username must be less than 13 characters
    error UsernameGreaterThan12Characters();

    /// username must be alphanumeric (okay to have number in front)
    error UsernameMustBeAlphaNumeric();

    modifier is_username_owner(string memory username) {
        if (msg.sender != username_to_address[username]) {
            revert NotUsernameOwner();
        }
        _;
    }

    function is_alphanumeric(bytes memory username) private pure returns (bool) {
        // make sure username is alphanumeric (trick taken from stackoverflow somewhere)
        for (uint256 i = 0; i < username.length; i++) {
            bytes1 char = username[i];
            if (
                //         0               9                 A               Z                 a               z
                !((char >= 0x30 && char <= 0x39) || (char >= 0x41 && char <= 0x5A) || (char >= 0x61 && char <= 0x7A))
            ) return false;
        }

        return true;
    }

    modifier meets_username_requirements(string memory username) {
        // make sure username and address haven't been registered yet
        if (username_to_address[username] != 0x0000000000000000000000000000000000000000) revert UsernameAlreadyTaken();
        if (bytes(address_to_username[msg.sender]).length != 0) revert SenderAddressAlreadyRegistered();

        // check username constraints
        bytes memory b = bytes(username);
        if (b.length < 3) revert UsernameFewerThan3Characters();
        if (b.length > 12) revert UsernameGreaterThan12Characters();
        if (!is_alphanumeric(b)) revert UsernameMustBeAlphaNumeric();

        // done with checks. continue
        _;
    }

    /// Register an unregistered username as your own
    function register(string memory username) public meets_username_requirements(username) {
        username_to_address[username] = msg.sender;
        address_to_username[msg.sender] = username;
    }
}
