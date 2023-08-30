// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import {Test} from "../lib/forge-std/src/Test.sol";

import {Chatapp, Log} from "../src/Chatapp.sol";

contract ChatappTest is Test {
    Chatapp chatapp;
    address alice = address(1);
    address bob = address(2);

    constructor() {
        chatapp = new Chatapp();
        deal(alice, 1_000_000);
        deal(bob, 1_000_000);
    }

    function test_register_username() public {
        vm.prank(alice);
        chatapp.register_username("alice");
        assertEq(chatapp.address_to_username(alice), "alice");

        vm.expectRevert(Chatapp.UsernameAlreadyTaken.selector);
        chatapp.register_username("alice");
    }

    function setup_alice() public {
        vm.prank(alice);
        chatapp.register_username("alice");
    }

    function setup_bob() public {
        vm.prank(bob);
        chatapp.register_username("bob");
    }

    function test_send_message() public {
        setup_alice();
        setup_bob();

        string memory alice_msg_1 = "hi";
        string memory alice_msg_2 = "how have you been?";
        string memory bob_msg_1 = "yo!";
        string memory bob_msg_2 = "i'm doing well :)";
        string memory bob_msg_3 = "and you?";

        // send messages between alice and bob
        vm.prank(alice);
        chatapp.send_message("bob", 1, alice_msg_1);
        vm.prank(alice);
        chatapp.send_message("bob", 2, alice_msg_2);

        vm.prank(bob);
        chatapp.send_message("alice", 3, bob_msg_1);
        vm.prank(bob);
        chatapp.send_message("alice", 5, bob_msg_2);
        vm.prank(bob);
        chatapp.send_message("alice", 6, bob_msg_3);

        // get messages
        assertEq(chatapp.chatlog_number("alice_bob"), 2);
        assertEq(chatapp.chatlog_number("bob_alice"), 3);

        // check messages
        (uint256 timestamp, string memory message) = chatapp.chatlogs("alice_bob", 1);
        assertEq(timestamp, 2);
        assertEq(message, alice_msg_2);

        (timestamp, message) = chatapp.chatlogs("bob_alice", 2);
        assertEq(timestamp, 6);
        assertEq(message, bob_msg_3);
    }
}
