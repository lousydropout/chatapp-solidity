// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

struct Log {
    /// unix timestamp in milliseconds (to be determined by frontend client)
    uint256 timestamp;
    /// message
    string message;
}

contract Chatapp {
    mapping(string => address) public username_to_address;
    mapping(address => string) public address_to_username;

    /// chatlogs key: {sender_username}_{recipient_username}
    /// chatlogs value: an array of messages `sender_username` sent `recipient_username`
    mapping(string => Log[]) public chatlogs;

    /// chatlog_number key: {sender_username}_{recipient_username}
    /// chatlog_number value: number of messages `sender_username` sent `recipient_username`
    mapping(string => uint256) public chatlog_number;

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

    /// recipient does not exist
    error RecipientDoesNotExist();

    /// sender needs to register a username first
    error SenderNotRegistered();

    /// check if username is alphanumeric
    function is_alphanumeric(bytes memory username) private pure returns (bool) {
        for (uint256 i = 0; i < username.length; i++) {
            bytes1 char = username[i];
            if (
                //         0               9                 A               Z                 a               z
                !((char >= 0x30 && char <= 0x39) || (char >= 0x41 && char <= 0x5A) || (char >= 0x61 && char <= 0x7A))
            ) return false;
        }

        return true;
    }

    /// check if username is valid
    modifier is_valid_username(string memory username) {
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

    modifier recipient_exists(string memory recipient) {
        if (username_to_address[recipient] == 0x0000000000000000000000000000000000000000) {
            revert RecipientDoesNotExist();
        }
        _;
    }

    /// Register an unregistered username as your own
    function register_username(string memory username) public is_valid_username(username) {
        username_to_address[username] = msg.sender;
        address_to_username[msg.sender] = username;
    }

    /// Get the username of `msg.sender`
    function get_sender_username() private view returns (string memory) {
        string memory username = address_to_username[msg.sender];
        if (bytes(username).length == 0) revert SenderNotRegistered();
        return username;
    }

    /// send a message to `recipient`
    function send_message(string memory recipient, uint256 timestamp, string memory message)
        public
        recipient_exists(recipient)
    {
        string memory key = string.concat(get_sender_username(), "_", recipient);
        chatlogs[key].push(Log(timestamp, message));
        chatlog_number[key] += 1;
    }
}
