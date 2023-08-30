// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import {Test} from "../lib/forge-std/src/Test.sol";
import {Chatapp, Log} from "../src/Chatapp.sol";

contract ChatappTest is Test {
    Chatapp chatapp;
    address alice = address(1);
    address bob = address(2);
    string u_alice = "alice";
    string u_bob = "bob";

    constructor() {
        chatapp = new Chatapp();
        deal(alice, 1_000_000);
        deal(bob, 1_000_000);
    }

    function test_register_username() public {
        vm.prank(alice);
        chatapp.register_username(u_alice);
        assertEq(chatapp.address_to_username(alice), u_alice);
    }

    function test_username_already_registered() public {
        vm.prank(alice);
        chatapp.register_username(u_alice);
        assertEq(chatapp.address_to_username(alice), u_alice);

        vm.expectRevert(Chatapp.UsernameAlreadyTaken.selector);
        vm.prank(alice);
        chatapp.register_username(u_alice);
    }

    function test_sender_already_registered() public {
        vm.prank(alice);
        chatapp.register_username(u_alice);
        assertEq(chatapp.address_to_username(alice), u_alice);

        vm.expectRevert(Chatapp.SenderAddressAlreadyRegistered.selector);
        vm.prank(alice);
        chatapp.register_username(u_bob);
    }

    function setup_alice() public {
        vm.prank(alice);
        chatapp.register_username(u_alice);
    }

    function setup_bob() public {
        vm.prank(bob);
        chatapp.register_username(u_bob);
    }

    function test_valid_and_invalid_usernames() public {
        vm.expectRevert(Chatapp.UsernameFewerThan3Characters.selector);
        vm.prank(alice);
        chatapp.register_username("aa");

        vm.expectRevert(Chatapp.UsernameGreaterThan12Characters.selector);
        vm.prank(alice);
        chatapp.register_username("abcdefghijklmnopqrstuvwxyz");

        vm.expectRevert(Chatapp.UsernameMustBeAlphaNumeric.selector);
        vm.prank(alice);
        chatapp.register_username("abc_def");
    }

    function test_cannot_send_message_before_registering() public {
        setup_bob();

        vm.expectRevert(Chatapp.SenderNotRegistered.selector);
        vm.prank(alice);
        chatapp.send_message(u_bob, 1, "hi");
    }

    function test_cannot_send_message_to_unregistered_user() public {
        setup_alice();

        vm.expectRevert(Chatapp.RecipientDoesNotExist.selector);
        vm.prank(alice);
        chatapp.send_message(u_bob, 1, "hi");
    }

    function test_alice_chats_with_bob() public {
        setup_alice();
        setup_bob();

        string memory alice_msg_1 = "hi";
        string memory alice_msg_2 = "how have you been?";
        string memory bob_msg_1 = "yo!";
        string memory bob_msg_2 = "i'm doing well :)";
        string memory bob_msg_3 = "and you?";

        // send messages between alice and bob
        vm.prank(alice);
        chatapp.send_message(u_bob, 1, alice_msg_1);
        vm.prank(alice);
        chatapp.send_message(u_bob, 2, alice_msg_2);

        vm.prank(bob);
        chatapp.send_message(u_alice, 3, bob_msg_1);
        vm.prank(bob);
        chatapp.send_message(u_alice, 5, bob_msg_2);
        vm.prank(bob);
        chatapp.send_message(u_alice, 6, bob_msg_3);

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
