import pytest
from eth_utils import to_wei

@pytest.fixture
def vault(get_contract):
    """Deploy Vault contract"""
    return get_contract("Vault")

def test_deployment(vault, accounts):
    """Test contract deployment"""
    assert vault.owner() == accounts[0]

def test_deposit(vault, accounts, get_logs):
    """Test ETH deposit"""
    user = accounts[1]
    deposit_amount = to_wei(1, 'ether')

    # Deposit ETH
    tx = vault.deposit(sender=user, value=deposit_amount)

    # Check balance
    assert vault.getBalance(user) == deposit_amount
    assert vault.getContractBalance() == deposit_amount

    # Check event
    logs = get_logs(tx, vault, "Deposit")
    assert len(logs) == 1
    assert logs[0].args.sender == user
    assert logs[0].args.amount == deposit_amount

def test_multiple_deposits(vault, accounts):
    """Test multiple deposits from same user"""
    user = accounts[1]
    first_deposit = to_wei(1, 'ether')
    second_deposit = to_wei(2, 'ether')

    vault.deposit(sender=user, value=first_deposit)
    vault.deposit(sender=user, value=second_deposit)

    assert vault.getBalance(user) == first_deposit + second_deposit
    assert vault.getContractBalance() == first_deposit + second_deposit

def test_deposit_zero_fails(vault, accounts):
    """Test that depositing 0 ETH fails"""
    user = accounts[1]

    with pytest.raises(Exception):
        vault.deposit(sender=user, value=0)

def test_withdraw(vault, accounts, get_logs):
    """Test ETH withdrawal"""
    user = accounts[1]
    deposit_amount = to_wei(2, 'ether')
    withdraw_amount = to_wei(1, 'ether')

    # Deposit first
    vault.deposit(sender=user, value=deposit_amount)

    # Get initial user balance
    initial_balance = user.balance

    # Withdraw
    tx = vault.withdraw(withdraw_amount, sender=user)

    # Check balances
    assert vault.getBalance(user) == deposit_amount - withdraw_amount
    assert vault.getContractBalance() == deposit_amount - withdraw_amount

    # Check event
    logs = get_logs(tx, vault, "Withdraw")
    assert len(logs) == 1
    assert logs[0].args.recipient == user
    assert logs[0].args.amount == withdraw_amount

def test_withdraw_insufficient_balance(vault, accounts):
    """Test withdraw with insufficient balance fails"""
    user = accounts[1]

    with pytest.raises(Exception):
        vault.withdraw(to_wei(1, 'ether'), sender=user)

def test_withdraw_zero_fails(vault, accounts):
    """Test withdrawing 0 ETH fails"""
    user = accounts[1]

    # Deposit first
    vault.deposit(sender=user, value=to_wei(1, 'ether'))

    with pytest.raises(Exception):
        vault.withdraw(0, sender=user)

def test_multiple_users(vault, accounts):
    """Test multiple users using the vault"""
    user1 = accounts[1]
    user2 = accounts[2]
    deposit1 = to_wei(1, 'ether')
    deposit2 = to_wei(2, 'ether')

    # Both users deposit
    vault.deposit(sender=user1, value=deposit1)
    vault.deposit(sender=user2, value=deposit2)

    # Check individual balances
    assert vault.getBalance(user1) == deposit1
    assert vault.getBalance(user2) == deposit2
    assert vault.getContractBalance() == deposit1 + deposit2

    # User1 withdraws
    vault.withdraw(deposit1, sender=user1)
    assert vault.getBalance(user1) == 0
    assert vault.getBalance(user2) == deposit2
    assert vault.getContractBalance() == deposit2
