# @version ^0.3.9
"""
@title Simple Vault Contract
@notice Deposit and withdraw ETH with event logging
@dev Demonstrates Vyper's payable functions and storage
"""

# Events
event Deposit:
    sender: indexed(address)
    amount: uint256
    balance: uint256

event Withdraw:
    recipient: indexed(address)
    amount: uint256
    balance: uint256

# State Variables
balances: public(HashMap[address, uint256])
owner: public(address)

@external
def __init__():
    """
    @notice Initialize the vault with deployer as owner
    """
    self.owner = msg.sender

@external
@payable
def deposit():
    """
    @notice Deposit ETH into the vault
    @dev Increases sender's balance
    """
    assert msg.value > 0, "Must send ETH"

    self.balances[msg.sender] += msg.value

    log Deposit(msg.sender, msg.value, self.balances[msg.sender])

@external
def withdraw(_amount: uint256):
    """
    @notice Withdraw ETH from the vault
    @param _amount The amount to withdraw
    """
    assert _amount > 0, "Amount must be greater than 0"
    assert self.balances[msg.sender] >= _amount, "Insufficient balance"

    self.balances[msg.sender] -= _amount

    # Send ETH to the user
    raw_call(msg.sender, b"", value=_amount)

    log Withdraw(msg.sender, _amount, self.balances[msg.sender])

@external
@view
def getBalance(_account: address) -> uint256:
    """
    @notice Get the balance of an account
    @param _account The account to query
    @return The account's balance
    """
    return self.balances[_account]

@external
@view
def getContractBalance() -> uint256:
    """
    @notice Get the total ETH held by the contract
    @return The contract's ETH balance
    """
    return self.balance
