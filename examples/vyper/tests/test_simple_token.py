import pytest
from eth_account import Account

# Test constants
TOKEN_NAME = "VyperToken"
TOKEN_SYMBOL = "VYP"
TOKEN_DECIMALS = 18
INITIAL_SUPPLY = 1_000_000 * 10**18

@pytest.fixture
def simple_token(get_contract):
    """Deploy SimpleToken contract"""
    return get_contract("SimpleToken", TOKEN_NAME, TOKEN_SYMBOL, TOKEN_DECIMALS, INITIAL_SUPPLY)

def test_deployment(simple_token, accounts):
    """Test contract deployment and initial state"""
    assert simple_token.name() == TOKEN_NAME
    assert simple_token.symbol() == TOKEN_SYMBOL
    assert simple_token.decimals() == TOKEN_DECIMALS
    assert simple_token.totalSupply() == INITIAL_SUPPLY
    assert simple_token.balanceOf(accounts[0]) == INITIAL_SUPPLY

def test_transfer(simple_token, accounts):
    """Test token transfer"""
    sender = accounts[0]
    recipient = accounts[1]
    amount = 100 * 10**18

    # Check initial balances
    initial_sender_balance = simple_token.balanceOf(sender)
    initial_recipient_balance = simple_token.balanceOf(recipient)

    # Transfer tokens
    tx = simple_token.transfer(recipient, amount, sender=sender)

    # Check final balances
    assert simple_token.balanceOf(sender) == initial_sender_balance - amount
    assert simple_token.balanceOf(recipient) == initial_recipient_balance + amount

def test_transfer_insufficient_balance(simple_token, accounts):
    """Test transfer with insufficient balance fails"""
    sender = accounts[1]  # Account with no tokens
    recipient = accounts[2]
    amount = 100 * 10**18

    with pytest.raises(Exception):
        simple_token.transfer(recipient, amount, sender=sender)

def test_approve_and_transfer_from(simple_token, accounts):
    """Test approve and transferFrom"""
    owner = accounts[0]
    spender = accounts[1]
    recipient = accounts[2]
    amount = 100 * 10**18

    # Approve spender
    simple_token.approve(spender, amount, sender=owner)
    assert simple_token.allowance(owner, spender) == amount

    # Transfer from owner to recipient
    initial_owner_balance = simple_token.balanceOf(owner)
    initial_recipient_balance = simple_token.balanceOf(recipient)

    simple_token.transferFrom(owner, recipient, amount, sender=spender)

    assert simple_token.balanceOf(owner) == initial_owner_balance - amount
    assert simple_token.balanceOf(recipient) == initial_recipient_balance + amount
    assert simple_token.allowance(owner, spender) == 0

def test_transfer_from_insufficient_allowance(simple_token, accounts):
    """Test transferFrom with insufficient allowance fails"""
    owner = accounts[0]
    spender = accounts[1]
    recipient = accounts[2]
    amount = 100 * 10**18

    # Approve less than transfer amount
    simple_token.approve(spender, amount // 2, sender=owner)

    with pytest.raises(Exception):
        simple_token.transferFrom(owner, recipient, amount, sender=spender)
